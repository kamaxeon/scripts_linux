#!/usr/bin/python
# -*- encoding: utf-8 -*-


# Autor: Israel Santana <isra@miscorreos.org>

# Versión: 0.1

# Licencia: GPL v2

## Script para generar archivo g729 en el directorio
## y de forma recursiva, en necesario tener el codecs g729
## y activado en el asterisk y funcionando

import os
import os.path
import copy


def get_file_and_extension(file):
	return os.path.splitext(file)

def convert_to(file, codec):

	# Ahora tenemos que quitarle /var/lib/asterisk/sounds le descontamos
	# los primeros 25 caracteres
	src = file[25:]
	dst =  get_file_and_extension(src)[0] + '.' + codec
	os.system('asterisk -rx  "file convert %s %s"' %(src, dst))

def get_files(dir, extensions):
	

	# Creamos la lista de ficheros que vamos a devolver
	files = []

	# Ahora comprobamos que los ficheros y vemos que son ficheros
	# con las extensiones que buscamos y ademas no están repetidos

	## Recogemos los ficheros, directorios y demás
	for dirname, dirnames, filenames in os.walk(dir):

		for filename in filenames:
			f = os.path.join(dirname, filename)	
			file, extension = get_file_and_extension(filename)
			if (file not in files and extension in extensions):
				files.append(f)

	return files

def main():
	dir_base = '/var/lib/asterisk/sounds'
	extensions = ['.gsm', '.vaw']
	codec = 'g729'
	files = get_files (dir_base, extensions)
	for file in files:
		convert_to(file, codec) 


if __name__ == '__main__':
	main()