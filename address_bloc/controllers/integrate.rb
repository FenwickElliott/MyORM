module integratee
#   def set
#     begin
#         self.get_table('address_book')
#     rescue
#         self.create_table('address_book', {name: "VARCHAR(30)"})
#     end
#     begin
#         self.get_table('entry')
#     rescue
#         self.create_table('entry',{
#             address_book_id: 'INTEGER',
#             name: 'VARCHAR(30)',
#             phone_number: 'VARCHAR(30)',
#             email: 'VARCHAR(30)'
#         }, [['address_book_id', 'address_book(id)']] )
#     end
#     @set_up = true
#   end

#   def drop_tables
#     self.drop_table('entry')
#     self.drop_table('address_book')
#     @set_up = false
#   end
end