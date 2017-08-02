require 'sqlite3'

class BlocRecord
    attr_accessor :table

    def initialize(default_table)
        @db = SQLite3::Database.new(".data.db")
        @table = (default_table)
    end

    def bark
        puts "Woof!"
    end

    def db
        @db
    end

    def create_table(title, schema, foreign_keys = [])
        begin
            cmd = "CREATE TABLE #{title} (\n id INTEGER PRIMARY KEY,\n"
            schema.each {|k,v| cmd << "#{k.to_s} #{v},\n"}
            foreign_keys.each {|k| cmd << "FOREIGN KEY (#{k[0]}) REFERENCES #{k[1]},\n"}
            cmd.slice!(-2) ; cmd << ');'
            db.execute cmd
            @table = title
            puts "Created #{title} table"
        rescue => e
            puts e
        end
    end

    def drop_table(title = @table)
        begin
            db.execute "DROP TABLE #{title};"
            puts "Droped #{title}"
        rescue => e
            puts e
        end
    end

    def schema(title = @table)
        unless @schema 
            begin
                @schema = {}
                db.table_info(title).each do |row|
                    @schema[row["name"]] = row["type"]
                end
                # puts @schema
            rescue => e
                puts e
            end
        end
        @schema
    end

    def insert(title = @table, data)
        begin
            cmd = "INSERT INTO #{title} ("
            data.each_with_index do |(k,v),i|
                cmd << k.to_s
                cmd << ', ' unless i == data.size - 1
            end
            cmd << ") VALUES ("
            data.each_with_index do |(k,v),i|
                cmd <<  "'" << v.to_s << "'"
                cmd << ', ' unless i == data.size - 1
            end
            cmd << ');'
            db.execute cmd
        rescue => e
            puts e
        end
    end

    def update(title = @table, id, data)
        data.each do |k,v|
            db.execute <<-SQL
                UPDATE #{title}
                SET #{k} = '#{v}'
                WHERE id = #{id};
            SQL
        end
    end

    def delete_by_id(title = @table, id)
        db.execute "DELETE FROM #{title} WHERE id = #{id};"
    end

    def count(title = @table)
        db.execute("SELECT COUNT(*) FROM #{title}")[0][0]
    end

    def get_table(title = @table)
        db.execute "SELECT * FROM #{title}"
    end

    def get_row(title = @table, id)
        db.execute("SELECT * FROM #{title} WHERE id = #{id};")[0]
    end

    def objectify_row(title = @table, id)
        row = get_row(title, id)
        scm = schema(title)
        res = {}
        scm.each_with_index do |(k,v),i|
            res[k] = row[i]
        end
        res
    end

    def print_table(title = @table)
        res = db.execute "SELECT * FROM #{title}"
        res.each {|row| puts row.inspect}
    end

    def find(title = @table, attribute, value)
        res = db.execute <<-SQL
            SELECT * FROM #{title} WHERE #{attribute} = '#{value}';
        SQL
    end

    def filter(title = @table, condition)
        res = db.execute <<-SQL
            SELECT * FROM #{title} WHERE #{condition};
        SQL
        res.each {|row| puts row.inspect}
    end
end