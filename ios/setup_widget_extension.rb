require 'xcodeproj'

project_path = 'ios/Runner.xcodeproj'
project = Xcodeproj::Project.open(project_path)

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
    config.build_settings['CURRENT_PROJECT_VERSION'] = '$(FLUTTER_BUILD_NUMBER)'
    config.build_settings['MARKETING_VERSION'] = '$(FLUTTER_BUILD_NAME)'
  end
  
  # Dosyaları proje grubuna ekle
  widget_group = project.main_group.find_subpath('CalendaWidget', true)
  widget_group.set_source_tree('<group>')
  widget_group.set_path('CalendaWidget')
  
  swift_file = widget_group.new_file('CalendaWidget.swift')
  info_file = widget_group.new_file('Info.plist')
  entitlements_file = widget_group.new_file('CalendaWidget.entitlements')
  
  widget_target.source_build_phase.add_file_reference(swift_file)
  
  # WidgetKit ve SwiftUI framework'lerini ekle
  widget_target.add_system_framework('WidgetKit')
  widget_target.add_system_framework('SwiftUI')
  
  # Runner hedefine bağımlılık olarak ekle
  runner_target = project.targets.find { |t| t.name == 'Runner' }
  runner_target.add_dependency(widget_target)
  
  # Embed App Extensions (PlugIns klasörüne gömme ve CodeSignOnCopy)
  embed_phase = runner_target.copy_files_build_phases.find { |p| p.name == 'Embed App Extensions' || p.dst_subfolder_spec == 13 }
  if embed_phase.nil?
    embed_phase = runner_target.new_copy_files_build_phase('Embed App Extensions')
    embed_phase.symbol_dst_subfolder_spec = :plug_ins
    embed_phase.dst_path = ''
  end
  
  product_ref = widget_target.product_reference
  build_file = embed_phase.add_file_reference(product_ref)
  build_file.settings = { 'ATTRIBUTES' => ['RemoveHeadersOnCopy', 'CodeSignOnCopy'] }
  
  project.save
  puts "✅ CalendaWidget hedefi başarıyla Runner.xcodeproj içine eklendi!"
else
  puts "ℹ️ CalendaWidget hedefi zaten mevcut."
end
