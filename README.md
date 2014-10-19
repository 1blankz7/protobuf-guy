Protobuf Guy
============

Simple command line tool to translate protobuf messages into code. One goal of the script is plattform independency, so you can use it either on OSX, Windows or Linux. 

The script is written in Ruby with some requirements.

The script will do a recursive search for 'protoc' and 'protogen' executables starting in the current folder. The default executables are located in the 'ProtoGeneratorBins' folder.

## Requirements

The tool is only tested with Ruby 1.9 on Windows 8 and Ubuntu 13.10. More environments will be tested in the future and reported in the tested secion below.
 
## Installation

The box should run out of the box. No installation necessary.

## Usage

You can run the following command from command line.

```BASH
# Unix
./protobuf-guy.rb -i tests -o tests/
# Windows
ruby protobuf-guy.rb -i tests -o tests/
```

The script creates four subdirectories in the `tests` directory and the translations for the supported languages. In the root of the output folder is a map `MessageTypes.txt` with in csv syntax, that contains all discovered proto messages and an index per message. This is useful because the protobuf messages aren't self identifying.

```CSV
0,Test
1,Test.InnerTest
2,Test.InnerTest2
3,Test.InnerTest.InnerInnerTest
```

To create nested messages in the MessagesTypes list, you must use the convention of `two spaces` as indentation for every nesting level.

## Tested

The script was currently tested with following configurations:

 * Ubuntu 13.10, Ruby 1.9: C++, Java, Python
 * Windows 8, Ruby 1.9: C++, Java, Python, C#
 * Windows 7: C++, Java, Python, C# (using ruby-1.9.3-p545)
## Changelog

 * 12.05.2014
 	* more verbose output
 	* only one call for java, c++ and python files
 	* use protoc option for import path
 * 29.04.2014
 	* Search for binaries, terminate if not found
 	* more verbose output
 	* use native directory separators
 	* create output directory if not exist

## TODO

 * improve documentation
 * refactor some methods and use classes
