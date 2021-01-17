def to_large(s):
    switch = {"a": "A", "b": "B", "c": "C", "d": "D", "e": "E", "f": "F"}
    try:
        return switch[s]
    except KeyError:
        return s

pwd = __file__[:-len("generate_memory.py")]
with open(pwd+"input.txt", "r") as fr:
    with open(pwd+"output.hex", "w") as fw:
        flash_or_sram = 0 # 0 is flash, 1 is sram        
        s_all = fr.readlines()
        count = 0
        if 0 == flash_or_sram:
            for s in s_all:
                count += 1
                if 2 == len(s):
                    fw.write("0"+to_large(s[0]))
                elif 3 == len(s):
                    fw.write(to_large(s[0])+to_large(s[1]))
                else:
                    raise RuntimeError()
        elif 1 == flash_or_sram:
            for s in s_all:
                count += 1
                if 2 == len(s):
                    fw.write("0"+to_large(s[0])+"00")
                elif 3 == len(s):
                    fw.write(to_large(s[0])+to_large(s[1])+"00")
                elif 4 == len(s):
                    fw.write(to_large(s[1])+to_large(s[2])+"0"+to_large(s[0]))
                elif 5 == len(s):
                    fw.write(to_large(s[2])+to_large(s[3])+to_large(s[0])+to_large(s[1]))
                else:
                    raise RuntimeError()
        else:
            raise RuntimeError()
        print(count)
