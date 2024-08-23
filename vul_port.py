import socket
from time import sleep

array = [20, 21, 23, 25, 53, 69, 80, 110, 135, 137, 139, 143, 161, 389, 443]


def throw_error(val):
    match val:
        case 20:
            print(f"\033[33m[OPEN] Port - {val}.")
        case 21:
            print(f"\033[31m[OPEN] Port - {val}")
        case 23:
            print(f"\033[31m[OPEN] Port - {val}")
        case 25:
            print(f"\033[33m[OPEN] Port - {val}.")
        case 53:
            print(f"\033[31m[OPEN] Port - {val}")
        case 69:
            print(f"\033[31m[OPEN] Port - {val}")
        case 80:
            print(f"\033[31m[OPEN] Port - {val}")
        case 110:
            print(f"\033[31m[OPEN] Port - {val}")
        case 135:
            print(f"\033[31m[OPEN] Port - {val}")
        case 137 | 138 | 139:
            print(f"\033[31m[OPEN] Port - {val}")
        case 143:
            print(f"\033[31m[OPEN] Port - {val}")
        case 161:
            print(f"\033[31m[OPEN] Port - {val}")
        case 389:
            print(f"\033[31m[OPEN] Port - {val}")
        case 443:
            print(f"\033[33m[OPEN] Port - {val}\n")
        case _:
            print(f"\033[31m[OPEN] Port - {val}")

    return
    

    


for port in array:
    print(f"\033[32mchecking port {port}")
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.settimeout(1)  
    result = sock.connect_ex(('localhost', port)) 
    if result == 0:
       throw_error(port)
    else:
        next
    sock.close()
    sleep(0.25)




