class CreateDatabase < ActiveRecord::Migration
  def change
      create_table :users do |t|
          t.string :playername
          t.integer :gamesplayed
		  t.integer :gameswon         		  
      end
      
      create_table :loggedusers do |t|
          t.string :username
          t.string :password
      end
      
	  create_table :gamestatuses do |t|
          t.integer :saveslot
		  
          t.string :player1
		  t.string :player2
		  
          t.integer :p1score
		  t.integer :p2score
         
          t.string :playerturn
		 
          t.string :matrix0
		  t.string :matrix1
		  t.string :matrix2
		  t.string :matrix3
		  t.string :matrix4
		  t.string :matrix5
		  
          t.string :board0
		  t.string :board1
		  t.string :board2
		  t.string :board3
		  t.string :board4
		  t.string :board5
		  
	  end
           Loggedusers.create(username: "Admin", password: "admin")
           Users.create(playername: "Admin", gamesplayed: 0, gameswon: 0)
          
  end
end
