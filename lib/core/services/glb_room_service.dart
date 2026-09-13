import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../models/diorama_item.dart';
import 'error_logger.dart';

/// 🎨 3D Diorama Oda Modeli Dinamik Silüet & Materyal Servisi
/// Kilitli eşyaları saydam renksiz silüet (hologram) haline getirir,
/// satın alınan eşyaları ise tam renkli dokularıyla anında odada gösterir.
class GlbRoomService {
  static final GlbRoomService _instance = GlbRoomService._internal();
  static GlbRoomService get instance => _instance;
  GlbRoomService._internal();

  Uint8List? _cachedOriginalGlb;

  /// Orijinal model dosyasını yükler
  Future<Uint8List> _loadOriginalGlb() async {
    if (_cachedOriginalGlb != null) return _cachedOriginalGlb!;
    final byteData = await rootBundle.load('assets/models/room_template.glb');
    _cachedOriginalGlb = byteData.buffer.asUint8List();
    return _cachedOriginalGlb!;
  }

  /// Kilitli eşyaları yarı saydam silüete dönüştürülmüş bayt dizisini üretir
  Future<Uint8List> generateFilteredGlbBytes({
    required Set<String> unlockedItemIds,
  }) async {
    try {
      final glbBytes = await _loadOriginalGlb();
      final byteData = ByteData.sublistView(glbBytes);

      // GLB Header (12 byte)
      final chunk0Len = byteData.getUint32(12, Endian.little);

      // JSON Chunk'ı oku
      final jsonBytes = glbBytes.sublist(20, 20 + chunk0Len);
      final jsonStr = utf8.decode(jsonBytes);
      final Map<String, dynamic> gltf = jsonDecode(jsonStr);

      // Saydam Silüet Materyalleri:
      // Kilitli eşyaların kendi orijinal renklerini koruyarak %32 yumuşak saydamlık verir.
      final materials = List<Map<String, dynamic>>.from(
        (gltf['materials'] as List).map((m) => Map<String, dynamic>.from(m as Map)),
      );

      final ghostMaterialIndexMap = <int, int>{};

      int getOrCreateGhostMaterial(int originalIndex) {
        if (ghostMaterialIndexMap.containsKey(originalIndex)) {
          return ghostMaterialIndexMap[originalIndex]!;
        }
        if (originalIndex < 0 || originalIndex >= materials.length) {
          return originalIndex;
        }

        final orig = materials[originalIndex];
        final ghost = Map<String, dynamic>.from(orig);
        final pbr = Map<String, dynamic>.from(orig['pbrMetallicRoughness'] as Map? ?? {});

        final origBaseColor = (pbr['baseColorFactor'] as List?)
                ?.map((c) => (c as num).toDouble())
                .toList() ??
            [1.0, 1.0, 1.0, 1.0];

        pbr['baseColorFactor'] = [
          origBaseColor.isNotEmpty ? origBaseColor[0] : 1.0,
          origBaseColor.length > 1 ? origBaseColor[1] : 1.0,
          origBaseColor.length > 2 ? origBaseColor[2] : 1.0,
          0.32, // Belli belirsiz, renkleri seçilen zarif saydamlık
        ];

        ghost['pbrMetallicRoughness'] = pbr;
        ghost['alphaMode'] = 'BLEND';
        ghost['doubleSided'] = true;
        ghost['name'] = '${orig['name']}_Ghost';

        materials.add(ghost);
        final newIndex = materials.length - 1;
        ghostMaterialIndexMap[originalIndex] = newIndex;
        return newIndex;
      }

      // Kilitli eşyaların mesh primitive'lerini kendi saydam renkli materyallerine yönlendir
      final meshes = List<Map<String, dynamic>>.from(gltf['meshes'] as List);

      final lockedMeshIndices = <int>{};
      for (final item in DioramaItem.floor1Items) {
        if (!unlockedItemIds.contains(item.id)) {
          lockedMeshIndices.addAll(item.meshIndices);
        }
      }

      for (var i = 0; i < meshes.length; i++) {
        if (lockedMeshIndices.contains(i)) {
          final mesh = Map<String, dynamic>.from(meshes[i]);
          final primitives = (mesh['primitives'] as List).map((p) {
            final prim = Map<String, dynamic>.from(p as Map);
            final origMatIndex = prim['material'] as int?;
            if (origMatIndex != null) {
              prim['material'] = getOrCreateGhostMaterial(origMatIndex);
            }
            return prim;
          }).toList();
          mesh['primitives'] = primitives;
          meshes[i] = mesh;
        }
      }
      gltf['materials'] = materials;
      gltf['meshes'] = meshes;

      // Boolean cutter Cube (Node 7 / mesh 7) güvenlik filtrelemesi
      if (gltf.containsKey('scenes') && (gltf['scenes'] as List).isNotEmpty) {
        final scene0 = Map<String, dynamic>.from(gltf['scenes'][0] as Map);
        if (scene0.containsKey('nodes')) {
          final sceneNodes = List<int>.from(scene0['nodes'] as List);
          sceneNodes.removeWhere((id) => id == 7);
          scene0['nodes'] = sceneNodes;
          gltf['scenes'][0] = scene0;
        }
      }

      // Yeni JSON Chunk'ı paketle
      var newJsonBytes = utf8.encode(jsonEncode(gltf));
      // 4 byte hizalaması için boşluk (space - 0x20) ekle
      final padLength = (4 - (newJsonBytes.length % 4)) % 4;
      if (padLength > 0) {
        final padded = Uint8List(newJsonBytes.length + padLength);
        padded.setRange(0, newJsonBytes.length, newJsonBytes);
        for (var i = newJsonBytes.length; i < padded.length; i++) {
          padded[i] = 0x20;
        }
        newJsonBytes = padded;
      }
      final newChunk0Len = newJsonBytes.length;

      // İkili (BIN) Chunk
      final binChunk = glbBytes.sublist(20 + chunk0Len);
      final newTotalLen = 12 + 8 + newChunk0Len + binChunk.length;

      // Yeni GLB bayt dizisini birleştir
      final result = BytesBuilder();

      // Header (12 bytes)
      final headerData = ByteData(12);
      headerData.setUint32(0, byteData.getUint32(0, Endian.little), Endian.little);
      headerData.setUint32(4, byteData.getUint32(4, Endian.little), Endian.little);
      headerData.setUint32(8, newTotalLen, Endian.little);
      result.add(headerData.buffer.asUint8List());

      // Chunk 0 Header (8 bytes)
      final chunk0Hdr = ByteData(8);
      chunk0Hdr.setUint32(0, newChunk0Len, Endian.little);
      chunk0Hdr.setUint32(4, byteData.getUint32(16, Endian.little), Endian.little);
      result.add(chunk0Hdr.buffer.asUint8List());

      // Chunk 0 Payload
      result.add(newJsonBytes);

      // Chunk 1 Payload
      result.add(binChunk);

      return result.toBytes();
    } catch (e, st) {
      ErrorLogger.log('GlbRoomService.generateFilteredGlbBytes', e, st);
      return _loadOriginalGlb();
    }
  }

  /// ModelViewer için Data URI üretir (anlık, sıfır dosya izni)
  Future<String> generateFilteredGlbDataUri({
    required Set<String> unlockedItemIds,
  }) async {
    final bytes = await generateFilteredGlbBytes(unlockedItemIds: unlockedItemIds);
    final base64String = base64Encode(bytes);
    return 'data:model/gltf-binary;base64,$base64String';
  }

  /// ModelViewer veya harici görüntüleyiciler için geçici dosya döner
  Future<File> generateFilteredGlbFile({
    required Set<String> unlockedItemIds,
  }) async {
    final bytes = await generateFilteredGlbBytes(unlockedItemIds: unlockedItemIds);
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/diorama_room_${unlockedItemIds.length}.glb');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }
}
