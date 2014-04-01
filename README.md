Protobuf Guy
============

Simple command line tool to translate protobuf messages into code. One goal of the script is plattform independency, so you can use it either on OSX, Windows or Linux. 

The script is written in Ruby with some requirements.

## Requirements


 
## Installation

To install protobuf please refer the install guide in the protobuf directory.

## Usage

You can run the following command from command line.

```BASH
# Unix
./protobuf-guy.rb -i tests -o tests/
# Windows
```

The script creates four subdirectories in the `tests` directory and the translations for the supported languages. In the root of the output folder is a map `MessageTypes` with in csv syntax, that contains all discovered proto files and a index per file. This is useful because the protobuf messages aren't self identifying.

```CSV
0,test
```

## Tested

The script was currently tested with following configurations:

 * Ubuntu 13.10: C++, Java, Python

## TODO

 * Nested Messages unterstützen
 * Namen in MessageTypes orientieren sich an Message-Namen
 * Nested Messages haben den Namen MessageName.NestedMessageName
 * alle Klassen werden in einen Ordner gelegt, wenn möglich sogar in eine Datei
 * Unterstüzung für Windows und C#
