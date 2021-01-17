while(1):
    filename = input("What is the text file?")
    if (filename == "q"):
        break
    f = open(("../sprite_bytes/text/" + filename + ".txt"))
    fout = open(("../sprite_bytes/text/" + filename + "_edge.txt"), "w")
    for line in f:
        if line == '6\n':
            fout.write('0\n')
        else:
            fout.write('1\n')
    f.close()
    fout.close()
