import sys

def main():
    # Your code here
    if len(sys.argv) > 1:
        parameters = sys.argv[2:]
        value = sum(int(x) for x in parameters if x.isdigit())
        
        print(f"Hello, {value}!")
    else:
        print("Hello, World!")


if __name__ == "__main__":
    main()