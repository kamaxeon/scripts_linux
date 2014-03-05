#!/usr/bin/python
# -*- encoding: utf-8 -*-


# Author: Israel Santana <isra@miscorreos.org>

# Version: 0.1

# License: GPL v2

# Script to generate random password

from random import randint
import argparse
from sys import exit

parser = argparse.ArgumentParser(description='Create random password')

parser.add_argument('--min', type=int, default=10, \
  help="Minimum characters of the password") 

parser.add_argument('--max', type=int, default=15, \
  help="Maximum characters of the password")

parser.add_argument('--num', type=int, default=1, \
  help="Numbers of passwords")

parser.add_argument('--com', type=int, default=1, \
  help="Minimum numbers of characters of every type: lower case, upper case, numbers \
  and specials characters")

args = parser.parse_args()

lower_abc     = 'abcdefghijklmnoprstuvwxyz'
upper_abc     = lower_abc.upper()
numbers        = '0123456789'
characters    = '.-,/()|!?/&$%#@[]' 
all_characters = lower_abc + upper_abc + numbers + characters
l = len(all_characters)

def check_password(passwd):
  rep = args.com
  if not check_dict_password(passwd, lower_abc):
    return False
  if not check_dict_password(passwd, upper_abc):
    return False
  if not check_dict_password(passwd, numbers):
    return False
  if not check_dict_password(passwd, characters):
    return False
  return True

def check_dict_password(passwd,dict):
  aux = 0
  for c in passwd:
    if c in dict:
      aux += 1
  return aux >= args.com

def create_password(length):
  aux_pwd = ''
  for i in range(length):
    c = randint(0,l-1)
    aux_pwd += all_characters[c]
  return aux_pwd


def print_password(pwd_lists):
  print 'Generated passwords'

  for passwd in pwd_lists:
    print '- %s' %(passwd) 


def check_parameters():
  if args.com * 4 > args.min:
    print '''
    Not possible generate passwords, increase the minimum number characters 
    or decrease the complexity'''
    exit(1)
  if args.min > args.max:
    print 'Minimum is higher than Maximum'
    exit(1)


def main():

  check_parameters()

  pwd_lists = []


  for i in range(args.num):
   created = False
   while not created:
     length = randint(args.min, args.max)
     passwd = create_password(length)
     created = check_password(passwd)
   pwd_lists.append(passwd)

  print_password(pwd_lists)

if __name__ == '__main__':
  main()