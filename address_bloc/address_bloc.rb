require_relative 'controllers/menu_controller'

menu = MenuController.new('entry')

system "clear"
puts "Welcome to AddressBloc!"
menu.main_menu
