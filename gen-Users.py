# import neccesary modules
from hashlib import sha1
import sys, os

#### Variabels
# filenames of the inputfile and outputfile
inputFile = "users-Unstructered.csv"
outputFileSystemUsers = "systemusers-done.pp"
outputFileMYsqlUsers = "mysqlusers-done.pp"

#Begin of the uids on the lamp-stack system
uid = 1001

# These are used to store the output for the files
resultSystemUsers = ""
resultMYsqlUsers = ""
mysqluser = ""
mysqldatabase = ""
mysqlgrants = ""

# Open the inputfile
file = open(inputFile, "r")

# begin the structured output for the files
resultSystemUsers += "class users {\n"
mysqluser += "\t\tusers => {"
mysqldatabase += "\t\tdatabases => {"
mysqlgrants += "\t\tgrants => {"

# read every person with password
for line in file:
	fields = line.split(";")
	field1 = fields[0]
	field2 = fields[1]
	# erase the witspaces and tabs
	field1name = "".join(field1.split() )
	field2pass = "".join(field2.split() )

	# First we will generate the users of the system in a file
	resultSystemUsers += "user {{ \"{}\":\n\tensure => present,\n\tpassword => pw_hash(\"{}\", \"SHA-256\", \"mysalt\"),\n\tuid => \"{}\",\n\tshell => \"/bin/bash\",\n\thome => \"/home/{}\",\n\tmanagehome => true,\n}}\n\n".format(field1name, field2pass, uid, field1name)
	uid += 1

	# now we will generate the mysql user txt file to use
	mysql_hash = "*" + sha1(sha1(field2pass.encode("utf-8")).digest()).hexdigest()
	mysqluser += "\n\t\t\t\"{}@localhost\" => {{\n\t\t\t\tensure => \"present\",\n\t\t\t\tmax_connections_per_hour => \"0\",\n\t\t\t\tmax_user_connections => \"0\",\n\t\t\t\tpassword_hash => \"{}\",\n\t\t\t}},\n".format(field1name, mysql_hash)
	mysqldatabase += "\n\t\t\t\"{}\" => {{\n\t\t\t\tensure => \"present\",\n\t\t\t\tcharset => \"utf8\",\n\t\t\t}},\n".format(field1name)
	mysqlgrants += "\n\t\t\t\"{}@localhost/{}.*\" => {{\n\t\t\t\tensure => \"present\",\n\t\t\t\toptions => [\"GRANT\"],\n\t\t\t\tprivileges => [\"ALL\"],\n\t\t\t\ttable => \"{}.*\",\n\t\t\t\tuser => \"{}@localhost\",\n\t\t\t}},".format(field1name, field1name, field1name, field1name)

# Close the structured output
resultSystemUsers += "}"
resultMYsqlUsers += mysqluser + "\n\t\t},\n" + mysqldatabase + "\n\t\t},\n" + mysqlgrants + "\n\t\t},\n"

# write the result for the systemusers to a file in the same directory as where the script runs
fileResultSystemUsers = open(outputFileSystemUsers, "w")
fileResultSystemUsers.write(resultSystemUsers)
fileResultSystemUsers.close()

# write the result for the mysqlusers to a file in the same directory as where the script runs
fileResultMYsqlUsers = open(outputFileMYsqlUsers, "w")
fileResultMYsqlUsers.write(resultMYsqlUsers)
fileResultMYsqlUsers.close()

# Close the inputfile
file.close()

# Print that the files have been generated
print ("The file have been generated!")