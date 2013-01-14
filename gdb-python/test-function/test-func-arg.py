#!/usr/bin/env /usr/bin/python

def func_a(arg):
	b=arg
	b.append(4)

def main():
	a=[1,2,3]
	func_a(a)
	print a

if __name__ == '__main__':
	main()
