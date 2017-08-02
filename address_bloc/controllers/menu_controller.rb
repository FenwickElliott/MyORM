require_relative '../models/address_book'
require 'bloc_record'
# require_relative 'integrate'

class MenuController < BlocRecord
  attr_reader :address_book

  def main_menu
    set unless @set_up
    puts "Main Menu - #{self.count('entry')} entries"
    puts "1 - View all entries"
    puts "2 - Create an entry"
    puts "3 - Search for an entry"
    puts "4 - Import entries from a CSV"
    puts "5 - Exit"
    print "Enter your selection: "

    selection = gets.to_i

    case selection
      when 1
        system "clear"
        view_all_entries
        main_menu
      when 2
        system "clear"
        create_entry
        main_menu
      when 3
        system "clear"
        search_entries
        main_menu
      when 4
        system "clear"
        read_csv
        main_menu
      when 5
        puts "Good-bye!"
        exit(0)
      when 666
        drop_tables
        system "clear"
        main_menu
      else
        system "clear"
        puts "Sorry, that is not a valid input"
        main_menu
      end
  end

  def view_all_entries(j = 0)
    res = self.get_table('entry')

    for i in j...res.length
      system 'clear'
      puts "Name: #{res[i][2]}\nPhone Number: #{res[i][3]}\nEmail: #{res[i][4]}"
      entry_submenu(res[i][0])
    end
    system "clear"
    puts "End of entries"
    main_menu
  end

  def create_entry
    system "clear"
    puts "New AddressBloc Entry"
    print "Name: "
    name = gets.chomp
    print "Phone number: "
    phone = gets.chomp
    print "Email: "
    email = gets.chomp

    self.insert('entry',{
      address_book_id: 1,
      name: name,
      phone_number: phone,
      email: email
    })

    system "clear"
    puts "New entry created"
  end

  def search_entries
    print "Search by name: "
    name = gets.chomp

    res = self.find('name', name)

    if res.size == 0
      puts "Sorry, #{name} isn't in this address book"
    elsif res.size == 1
      puts "Name: #{res[0][2]}\nPhone Number: #{res[0][3]}\nEmail: #{res[0][4]}"
      search_submenu(res[0][0])
    else
      puts "There are #{res.size} results for #{name}, you need a better system"
    end
  end

  def read_csv
    print "Enter CSV file to import: "
    file_name = gets.chomp

    if file_name.empty?
      system "clear"
      puts "No CSV file read"
      main_menu
    end

    begin
      entry_count = address_book.import_from_csv(file_name).count
      system "clear"
      puts "#{entry_count} new entries added from #{file_name}"
    rescue
      puts "#{file_name} is not a valid CSV file, please enter the name of a valid CSV file"
      read_csv
    end
  end

  def entry_submenu(entry_id)
    puts '-'
    puts "n - next entry"
    puts "d - delete entry"
    puts "e - edit this entry"
    puts "m - return to main menu"

    selection = gets.chomp

    case selection
      when "n"
      when "d"
        delete_entry(entry_id)
      when "e"
        edit_entry(entry_id)
        entry_submenu(entry_id-1)
      when "m"
        system "clear"
        main_menu
      else
        # system "clear"
        # puts "#{selection} is not a valid input"
        # entry_submenu(entry)
    end
  end

  def delete_entry(entry_id)
    begin
      self.delete_by_id(entry_id)
      puts "Deleted"
    rescue => e
      puts e
    end
  end

  def edit_entry(entry_id)
    print "Updated name: "
    name = gets.chomp
    print "Updated phone number: "
    phone_number = gets.chomp
    print "Updated email: "
    email = gets.chomp

    data = {}
    data['name'] = name if name.length > 0
    data['phone_number'] = phone_number if phone_number.length > 0
    data['email'] = email if email.length > 0

    self.update('entry', entry_id, data)

    system "clear"
    puts "Updated entry:"
    view_all_entries(entry_id)
  end

  def search_submenu(entry_id)
    puts "-\nd - delete entry"
    puts "e - edit this entry"
    puts "m - return to main menu"
    selection = gets.chomp

    case selection
      when "d"
        system "clear"
        delete_entry(entry_id)
        main_menu
      when "e"
        edit_entry(entry_id)
        system "clear"
        main_menu
      when "m"
        system "clear"
        main_menu
      else
        system "clear"
        puts "#{selection} is not a valid input"
        puts entry.to_s
        search_submenu(entry_id)
      end
    # end
  end

    def set
      begin
          self.get_table('address_book')
      rescue
          self.create_table('address_book', {name: "VARCHAR(30)"})
      end
      begin
          self.get_table('entry')
      rescue
          self.create_table('entry',{
              address_book_id: 'INTEGER',
              name: 'VARCHAR(30)',
              phone_number: 'VARCHAR(30)',
              email: 'VARCHAR(30)'
          }, [['address_book_id', 'address_book(id)']] )
      end
      @set_up = true
    end

    def drop_tables
      self.drop_table('entry')
      self.drop_table('address_book')
      @set_up = false
    end
end