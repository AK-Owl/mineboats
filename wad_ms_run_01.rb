# Ruby code file - All your code should be located between the comments provided.

# Add any additional gems and global variables here
require 'sinatra'
require 'sinatra/activerecord'
set :bind, '0.0.0.0'

# The file where you are to write code to pass the tests must be present in the same folder.
# See http://rspec.codeschool.com/levels/1 for help about RSpec

require "#{File.dirname(__FILE__)}/wad_ms_gen_01"

# Main program
module MS_Game
	@input = STDIN
	@output = STDOUT
	g = Game.new(@input, @output)
    $wg = Game.new(@input, @output)
	$playing = true
	$playingstatus == true
	$turn = ""
    $tr = 0
	    
	@output.puts 'Enter "1" runs game in command-line window or "2" runs it in web browser.'
	game = g.getinput
	if game == "1"
		@output.puts "Command line game"
	elsif game == "2"
		@output.puts "Web-based game"
	else
		@output.puts "Invalid input! No game selected."
		exit
	end
    # Command line interface gaming logic
        if game == "1"
            # Any code added to command line game should be added below.
            system 'clear'
            g.start
            g.displaymenu
            input = gets.chomp.to_i
            if input == 1
                $playing = true
                #randomise which player goes first
                $randomiser = rand(1..2)
                case $randomiser
                    when 1 then $turn = "P1"
                    when 2 then $turn = "P2"
                end

                g.setplayer1
                g.setplayer2

                g.clearscores
                g.clearcolumns
                g.createboard
                g.displaybegingame
                g.generatemines
                g.displayemptyframe
                g.assignmines

                while $playing == true
                    if $turn == "P1"
                        g.displayplayer1prompt
                    elsif $turn == "P2"
                        g.displayplayer2prompt
                    end

                    @output.puts "Please enter the row value"
                    row = gets.chomp
                    case row 
                        when "save"
                            g.savegame    
                        when "exit"
                            $playing = false
                            exit
                    else
                        row = row.to_i
                        if (row < 1 || row > 6)
                            g.displayinvalidinputerror
                        else
                            @output.puts "Please enter the column value"
                            col = gets.chomp
                            case col
                                 when "save"
                                    g.savegame    
                                when "exit"
                                    $playing = false
                                    exit
                            else
                                col=col.to_i
                                if (col < 1 || col > 7)
                                    g.displayinvalidinputerror
                                else
                                    row-=1
                                    col-=1
                                    g.getcolumnvalue(row,col)
                                    g.setmatrixcolumnvalue(row,col)
                                    g.updatematrix
                                    g.displayboard
                                    g.checkwinner
                                    
                                    if $turn == "P1"
                                        $turn = "P2"
                                    elsif $turn == "P2"
                                        $turn = "P1"
                                    end
                                end
                            end
                         end
                      end
                   end
            elsif input == 2
                        g.loadgame
                        g.displayboard
                        while $playing == true
                            if $turn == "P1"
                                g.displayplayer1prompt
                            elsif $turn == "P2"
                                g.displayplayer2prompt
                            end
                            @output.puts "Please enter the row value"
                            row = gets.chomp
                            case row 
                                when "save"
                                    g.savegame
                                when "exit"
                                    $playing = false
                                    exit
                            else
                                row = row.to_i
                                if (row < 1 || row > 6)
                                    g.displayinvalidinputerror
                                else
                                    @output.puts "Please enter the column value"
                                    col = gets.chomp
                                    case col 
                                        when "save"
                                            g.savegame
                                    when "exit"
                                        $playing = false
                                        exit
                                    else
                                        col=col.to_i
                                        if (col < 1 || col > 7)
                                            g.displayinvalidinputerror
                                        else
                                            row-=1
                                            col-=1
                                            g.getcolumnvalue(row,col)
                                            g.setmatrixcolumnvalue(row,col)
                                            g.updatematrix
                                            g.displayboard
                                            g.checkwinner
                                            
                                            if $turn == "P1"
                                               $turn = "P2"
                                            elsif $turn == "P2"
                                                $turn = "P1"
                                            end
                                        end
                                    end
                                end
                            end
                        end
            elsif input == 3
                g.leaderboard
            elsif input == 9
                exit
            else 
                g.displayinvalidinputerror
            end
              
	# Any code added to output the activity messages to the command line window should be added above.
    
		exit	# Does not allow command-line game to run code below relating to web-based version
	end

end
# End modules

# Sinatra routes

# Any code added to output the activity messages to a browser should be added below.
# 
get '/' do
    erb :home
end

# Web new game logic    
get '/game' do
        $playing = true
        #randomise which player goes first
        $randomiser = rand(1..2)
        case $randomiser
            when 1 then $turn = "P1"
            when 2 then $turn = "P2"
        end
        $opponent = "#{params[:opponent]}"
        $player2name = $opponent
        
        $systemtime1 = Time.new
        File.open("players.txt", "a") { |logfile| 
        logfile.write ("Player 1: ")
        logfile.write ($log_username)
        logfile.write ("  Player 2: ")
        logfile.write ($opponent)
        logfile.write (" Started the game... at   ") 
        logfile.write ($systemtime1.inspect)
        logfile.write "\n"}

        $wg.setopponent($opponent)        
        $wg.clearscores
        $wg.clearcolumns
        $wg.createboard
        $wg.generatemines
        $wg.assignmines
        erb :game
end
            
post '/game' do
    if $playing == true 
        $row = "#{params[:row]}" 
        $col = "#{params[:col]}"
        $row = $row.to_i
        $col=$col.to_i
                $row-=1
                $col-=1
                $wg.getcolumnvalue($row,$col)
                $wg.setmatrixcolumnvalue($row,$col)
                $wg.updatematrix
                $wg.displayboard
                $wg.checkwebwinner

                if $turn == "P1"
                    $turn = "P2"
                elsif $turn == "P2"
                    $turn = "P1"
                end
       if $playing == false
        $systemtime2 = Time.now
        File.open("players.txt", "a") { |logfile| 
        logfile.write ("Player 1: ")
        logfile.write ($log_username)
        logfile.write ("  Player 2: ")
        logfile.write ($opponent)
        logfile.write (" Finished the game... at   ") 
        logfile.write ($systemtime2.inspect)
        logfile.write ("   Time played for #{$systemtime2 - $systemtime1} Seconds ")
        logfile.write "\n"
        logfile.write "The winner is: #{$player}"
        logfile.write "\n"}
           erb :winner
       else
            erb :game
       end
    else
        erb :home
    end
end
  
get '/save' do
    $wg.savegame
    erb :game
end

get '/loadgame' do
    @games = Gamestatuses.all.sort_by {|g| [g.saveslot]}
    erb :loadgame
end

get '/load/:game' do
    $loadgame = params[:game]
    $wg.loadwebgame($loadgame)
    $playing = true
    erb :loadsavedgame
end

# load the saved the games logic implemented before
post '/loadsavedgame' do
    if $playing == true 
        $row = "#{params[:row]}" 
        $col = "#{params[:col]}"
        $row = $row.to_i
        $col=$col.to_i
                $row-=1
                $col-=1
                $wg.getcolumnvalue($row,$col)
                $wg.setmatrixcolumnvalue($row,$col)
                $wg.updatematrix
                $wg.displayboard
                $wg.checkwebwinner

                if $turn == "P1"
                    $turn = "P2"
                elsif $turn == "P2"
                    $turn = "P1"
                end
       if $playing == false
           erb :winner
       else
            erb :loadsavedgame
       end
    else
        erb :home
    end
end

get '/leaderboard' do
    @leaderboardlist = Users.all.sort_by {|u| [u.id]}
    erb :leaderboard
end

#Login authorization and Log file update
post '/login' do
$credentials = [params[:username],params[:password]]
@Users = Loggedusers.where(:username => $credentials[0]).to_a.first
    if @Users
         if @Users.password == $credentials[1]
             log_username = $credentials[0]
             $log_username = log_username
             $player1name = $log_username   
         redirect '/'
         else
             $credentials = ['','']
             redirect '/wrongaccount'
         end
     else
         $credentials = ['','']
         redirect '/wrongaccount'
    end
end

get '/player2' do
    erb :player
end

get '/login' do
    erb :login
end

get '/wrongaccount' do
    erb :wrongaccount
end

get '/createaccount' do
    erb :createaccount
end

get '/createaccountbyadmin' do
    erb :createaccountbyadmin
end

get '/userexist' do
    erb :userexist
end

get '/createaccountfail' do
    erb :createaccountfail
end

get '/createaccountsuccess' do
    erb :createaccountsuccess
end

get '/noaccount' do
    erb :noaccount
end

get '/denied' do
    erb :denied
end

get '/logout' do
    $credentials=['','']
    redirect '/'
end

post '/createaccount' do 
    users = Loggedusers.all
    users.each do |user|
        if user.username == params[:username]
            user.save
            redirect '/userexist'
        else
            n = Loggedusers.new
            n.username = params[:username]
            n.password = params[:password]
            if n.username == '' || n.password == ''
                redirect '/createaccountfail'
            else
                n.save
                p = Users.new
                p.playername = params[:username]
                p.gamesplayed = 0
                p.gameswon = 0
                p.save
            end
            redirect '/createaccountsuccess'
        end  
    end
end

# Any code added to output the activity messages to a browser should be added above.

# End program