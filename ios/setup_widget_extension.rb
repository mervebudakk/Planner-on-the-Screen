require 'xcodeproj'

project_path = 'ios/Runner.xcodeproj'
project = Xcodeproj::Project.open(project_path)

begin
  runner_target = project.targets.find { |t| t.name == 'Runner' }
  if runner_target.nil?
    raise "Runner hedefi bulunamadı!"
  end

  # 1. Widget hedefinin varlığını kontrol et
  widget_target = project.targets.find { |t| t.name == 'CalendaWidget' }

  if widget_target.nil?
    puts "🚀 CalendaWidget hedefi oluşturuluyor..."
    
    # Yeni App Extension hedefi oluştur
    widget_target = project.new_target(
      :app_extension,
      'CalendaWidget',
      :ios,
      '17.0'
    )
    
    team_id = 'S5S329QPX3'
    
    # Build ayarlarını yapılandır
    widget_target.build_configurations.each do |config|
      config.build_settings['PRODUCT_NAME'] = 'CalendaWidget'
      config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.calenda.app.CalendaWidget'
      config.build_settings['INFOPLIST_FILE'] = 'CalendaWidget/Info.plist'
      config.build_settings['CODE_SIGN_ENTITLEMENTS'] = 'CalendaWidget/CalendaWidget.entitlements'
      config.build_settings['SWIFT_VERSION'] = '5.0'
      config.build_settings['TARGETED_DEVICE_FAMILY'] = '1' # iPhone
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '17.0'
      config.build_settings['SKIP_INSTALL'] = 'YES'
      config.build_settings['GENERATE_INFOPLIST_FILE'] = 'NO'
      config.build_settings['DEVELOPMENT_TEAM'] = team_id
      config.build_settings['ENABLE_BITCODE'] = 'NO'
      config.build_settings['ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES'] = 'NO'
      config.build_settings['CURRENT_PROJECT_VERSION'] = '$(FLUTTER_BUILD_NUMBER)'
      config.build_settings['MARKETING_VERSION'] = '$(FLUTTER_BUILD_NAME)'
      config.build_settings['CODE_SIGN_STYLE'] = 'Manual'
      config.build_settings['PROVISIONING_PROFILE_SPECIFIER'] = 'CalendaWidget AppStore'
      config.build_settings['CODE_SIGN_IDENTITY'] = 'Apple Distribution'
      config.build_settings['CODE_SIGN_IDENTITY[sdk=iphoneos*]'] = 'Apple Distribution'
    end
    
    # Dosyaları proje grubuna ekle
    widget_group = project.main_group.find_subpath('CalendaWidget', true)
    widget_group.set_source_tree('<group>')
    widget_group.set_path('CalendaWidget')
    
    swift_file = widget_group.new_file('CalendaWidget.swift')
    info_file = widget_group.new_file('Info.plist')
    entitlements_file = widget_group.new_file('CalendaWidget.entitlements')
    
    widget_target.source_build_phase.add_file_reference(swift_file)
    
    # Runner hedefine bağımlılık olarak ekle (Widget önce derlenir)
    runner_target.add_dependency(widget_target)
    
    puts "✅ CalendaWidget hedefi başarıyla oluşturuldu!"
  else
    puts "ℹ️ CalendaWidget hedefi zaten mevcut."
  end

  # 2. Embed App Extensions Build Phase (PlugIns klasörüne kopyalama ve imzalama)
  all_embed_phases = runner_target.copy_files_build_phases.select { |p| p.name == 'Embed App Extensions' || p.dst_subfolder_spec.to_s == '13' }
  embed_phase = all_embed_phases.first

  if embed_phase.nil?
    embed_phase = runner_target.new_copy_files_build_phase('Embed App Extensions')
    embed_phase.symbol_dst_subfolder_spec = :plug_ins
    embed_phase.dst_path = ''
  end

  # Fazla mükerrer embed fazı varsa temizle
  if all_embed_phases.length > 1
    all_embed_phases[1..-1].each do |p|
      runner_target.build_phases.delete(p)
    end
  end

  # Widget ürün referansını ekle
  product_ref = widget_target.product_reference
  has_ref = embed_phase.files_references.any? { |r| r.name == 'CalendaWidget.appex' || r.path == 'CalendaWidget.appex' }
  unless has_ref
    build_file = embed_phase.add_file_reference(product_ref)
    build_file.settings = { 'ATTRIBUTES' => ['RemoveHeadersOnCopy', 'CodeSignOnCopy'] }
  end

  # ─────────────────────────────────────────────────────────────
  # 🔄 BUILD PHASES SIRALAMASI (Cycle inside Runner Çözümü)
  # 'Embed App Extensions' fazı 'Thin Binary' fazından MUTLAKA ÖNCE olmalıdır!
  # Xcode 15/16'da 'Thin Binary' sonrası eklenen 'Embed App Extensions', 
  # Info.plist ve PlugIns kopyalama arasında döngüsel bağımlılık (Cycle) oluşturur.
  # ─────────────────────────────────────────────────────────────
  thin_phase = runner_target.build_phases.find do |p|
    p.is_a?(Xcodeproj::Project::Object::PBXShellScriptBuildPhase) &&
      (p.name == 'Thin Binary' || p.shell_script.to_s.include?('embed_and_thin'))
  end

  if thin_phase && embed_phase
    runner_target.build_phases.delete(embed_phase)
    thin_index = runner_target.build_phases.index(thin_phase)
    runner_target.build_phases.insert(thin_index, embed_phase)
    puts "🔄 'Embed App Extensions' fazı 'Thin Binary' öncesine başarıyla taşındı."
  end

  puts "📋 Güncel Runner Build Phases sıralaması:"
  runner_target.build_phases.each_with_index do |phase, idx|
    puts "  #{idx + 1}. #{phase.display_name} (#{phase.class.name.split('::').last})"
  end

  project.save
  puts "✅ Xcode projesi başarıyla güncellendi ve kaydedildi!"
rescue => e
  puts "❌ Setup hatası: #{e.message}"
  puts e.backtrace
  exit 1
end
