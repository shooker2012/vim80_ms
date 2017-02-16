def remove_new_line_at_eof( file_name ):
    lines = None
    with open( file_name, 'r' ) as f:
        lines = f.readlines()

    if lines == None:
        return False

    if len(lines) == 0:
        return True

    lines[-1] = lines[-1].rstrip( '\n' )
    with open( file_name, 'w' ) as f:
        f.writelines( lines )
        return True

    return False

if __name__ == "__main__":
    import sys
    for f in sys.argv[1:]:
        remove_new_line_at_eof( f )
