import re
def escape_argument(arg):
	# Escape the argument for the cmd.exe shell.
	# See http://blogs.msdn.com/b/twistylittlepassagesallalike/archive/2011/04/23/everyone-quotes-arguments-the-wrong-way.aspx
	#
	# First we escape the quote chars to produce a argument suitable for
	# CommandLineToArgvW. We don't need to do this for simple arguments.

	if not arg or re.search(r'(["\s])', arg):
		arg = '"' + arg.replace('"', r'\"') + '"'

	return escape_for_cmd_exe(arg)

def escape_for_cmd_exe(arg):
	# Escape an argument string to be suitable to be passed to
	# cmd.exe on Windows
	#
	# This method takes an argument that is expected to already be properly
	# escaped for the receiving program to be properly parsed. This argument
	# will be further escaped to pass the interpolation performed by cmd.exe
	# unchanged.
	#
	# Any meta-characters will be escaped, removing the ability to e.g. use
	# redirects or variables.
	#
	# @param arg [String] a single command line argument to escape for cmd.exe
	# @return [String] an escaped string suitable to be passed as a program
	#	argument to cmd.exe

	meta_chars = '()%!^"<>&|'
	meta_re = re.compile('(' + '|'.join(re.escape(char) for char in list(meta_chars)) + ')')
	meta_map = { char: "^%s" % char for char in meta_chars }

	def escape_meta_chars(m):
		char = m.group(1)
		return meta_map[char]

	return meta_re.sub(escape_meta_chars, arg)

import subprocess
import remove_new_line_at_eof
import os

def get_change_file_list( folder ):
	cmd = 'svn status {0}'.format( escape_argument( folder ) )
	# print( "command line:", cmd )

	p = subprocess.Popen(cmd, stdout=subprocess.PIPE, shell=True)
	(output, err) = p.communicate()
	# print( "output:", output )

	# output = output.decode('string_escape') # python2
	# output = output.decode("unicode_escape") # python3

	output = output.split('\r\n')

	file_name_re = re.compile(r'^\S+\s+(.+)')
	modified_file_list = []

	for result in output:
		if not result:
			continue 

		# print( "result", result )
		file_name = file_name_re.search( result ).group(1)
		if not os.path.isfile(file_name):
			continue

		# filter files
		# _, ext = os.path.splitext( file_name )
		# if ext != ".lua":
		#	continue

		if result[0] == "M":
			modified_file_list.append( file_name )
		elif result[0] == "A":
			modified_file_list.append( file_name )

	print( "Waiting to fix:" )
	print( modified_file_list )
	print( "\n" )
	
	raw_input( "Press any key to continue..." )

	for f in modified_file_list:
		if remove_new_line_at_eof.remove_new_line_at_eof( f ):
			print( "{0:30}: remove new line at EOF.".format(f) )

if __name__ == "__main__":
	import sys
	get_change_file_list( sys.argv[1].strip('"') if len(sys.argv) >= 2 else ""	)
