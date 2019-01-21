class Dog 
  
  attr_accessor :name, :breed
  attr_reader :id 
  
  def initialize(name:, breed:, id: nil)
    @name = name 
    @breed = breed 
    @id = id 
  end 
  
  def self.create_table
    sql =  <<-SQL 
		      CREATE TABLE IF NOT EXISTS dogs (
		        id INTEGER PRIMARY KEY, 
		        name TEXT, 
		        breed TEXT
		        )
		        SQL
		    DB[:conn].execute(sql) 
	end
	
	def self.drop_table
	  sql =  <<-SQL 
		      DROP TABLE dogs 
		        SQL
		    DB[:conn].execute(sql) 
	end 
		
  def save
    if self.id 
      self.update
    else 
      sql = <<-SQL
		      INSERT INTO dogs (name, breed) 
		      VALUES (?, ?) 
		    SQL
		
		    DB[:conn].execute(sql, self.name, self.breed)
		
		    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end
  
  def self.create(attributes_hash)
    dog = Dog.new(name: attributes_hash[:name], breed: attributes_hash[:breed])
		dog.save
	end
	
	def self.find_by_id(id)
	  sql = "SELECT * FROM dogs WHERE id = ?"
		    result = DB[:conn].execute(sql, id)[0]
		    Dog.new(name: result[1], breed: result[2], id: result[0])
	end
	
	def self.find_or_create_by(name:, breed:)
	  dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
		    
		if !dog.empty?
		  dog_data = dog[0]
		  dog = Dog.new(name: dog_data[1], breed: dog_data[2], id: dog_data[0])
		else
		  dog = self.create(name: name, breed: breed)
		end
		dog
	end
	
	def self.new_from_db(row)
	  new_dog = self.new
		new_dog.id = row[0]
		new_dog.name =  row[1]
		new_dog.breed = row[2]
		new_dog
	end
  
end
