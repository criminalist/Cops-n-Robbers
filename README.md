
# Cops-n-Robbers
## Repository Information

This repository is the collection of the latest version of Cops and Robbers for
FiveM. This gamemode is written in Lua, with graphical interface written in 
HTML, CSS and Javascript(JQuery).

## Gamemode Information 

Cops and Robbers (hereforth 'CNR') is a game where regular civilians can choose
to either commit a crime and run from the cops, live a legitimate life, or 
join the force and chase the bad guys. The CNR game does NOT focus on quality
of life, such as realistic naming or licensing. The point of the game is to 
have quick action, run from the cops, chase bad guys, shoot people, and gain
cash.

## Self-Sufficient Gamemode / Dependencies

The goal is to be a self-sufficient gamemode. This means, while currently we
use the base resources and GHMattiMySQL, the intention is that we will over time
have our own integration with SQL, and handle our own chat and spawning events.
In the interest of time, we're using dependencies.

If you do not want to use GHMattiMySQL, spawnmanager, or any of those other
resources while you contribute, simply change the dependencies in the base
gamemode resource (cnrobbers).

## Developer Information

If you wish to contribute or help in the development of this gamemode, you can 
create your own fork of the project. If you wish to test the script on your own
server, you will need to provide an SQL database.

Please note the coding convention at the bottom of this ReadMe before submitting
a pull request.

An SQL file has been provided for you to be able to run your own server. Simply
import the file into an SQL database, and use a resource to connect to it. Once
impoted, the game mode will do the rest. Be sure to restart the server after 
importing the database.

## Copyright Information

Anyone is free to create their own servers with the files in this repository. 
All files in the repository have an open license and can be used in any way. FiveM
terms of use prohibit any profit from using their service, and this gamemode is 
provided for the community to host a unique game. All credit, if given, should
go to the original creator as well as the contributors as applicable.

## Resource Files

All details of what each individual resource controls and is used for
is located in the header of the __resource.lua file.

  * [Blips & Radar Info](https://github.com/rhapidfyre/Cops-n-Robbers/tree/master/cnr_blips)
  * [Cash & Banking](https://github.com/rhapidfyre/Cops-n-Robbers/tree/master/cnr_cash)
  * [Character Creation](https://github.com/rhapidfyre/Cops-n-Robbers/tree/master/cnr_charcreate)
  * [Chat & Notifications](https://github.com/rhapidfyre/Cops-n-Robbers/tree/master/cnr_chat)
  * [Clans](https://github.com/rhapidfyre/Cops-n-Robbers/tree/master/cnr_clans)
  * [Death](https://github.com/rhapidfyre/Cops-n-Robbers/tree/master/cnr_death)
  * [Law Enforcement](https://github.com/rhapidfyre/Cops-n-Robbers/tree/master/cnr_police)
  * [Robberies & Heists](https://github.com/rhapidfyre/Cops-n-Robbers/tree/master/cnr_robberies)
  * [Scoreboard](https://github.com/rhapidfyre/Cops-n-Robbers/tree/master/cnr_scoreboard)
  * [Wanted Script](https://github.com/rhapidfyre/Cops-n-Robbers/tree/master/cnr_wanted)
  
## Pull Requests

To submit your code to the master branch, the coding convention must be (mostly)
followed. I'll put some extra work in for your first few contributions, but if it becomes
a reocurring issue, I will stop accepting pull requests from you. If you make any 
changes to the DATABASE, be sure to include an updated SQL file, so we can update
our databases to match, or there will be errors and inconsistencies.

TL;DR - Any changes to SQL schema must be included in your pull request.

## Code Convention

Any notes made that require revisiting or changing later must be exactly "-- DEBUG -",
which is the search term we will look for when finalizing a script. There should 
be NO "--DEBUG -" comments on the finished product.

Ensure that your comments and descriptions are in accordance with
http://keplerproject.github.io/luadoc/ for when we move to a wiki page
(this is a Lua parser). This parser will use the format given in LDoc
to generate a wiki page. LDoc is based off of Doxygen.

On top of complying with LDoc, all code submitted must conform to the following:
* Double spacing between all functions and variables
* Space at the top of the file before the first line of code
* Code not easy to decipher must have accompanying comments
* All resources must either have
** 1) a README file to explain what exports are available, OR 
** 2) a detailed explanation of what exports are available in the resource file

Try to keep to an 80 character maximum per line, but do not sacrifice easily-readable code for a spacing requirement.
I.e: It is not necessary to break a print string into 3 lines just to fit within 80 chars

