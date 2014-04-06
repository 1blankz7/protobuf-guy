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
ruby protobuf-guy.rb -i tests -o tests/
```

The script creates four subdirectories in the `tests` directory and the translations for the supported languages. In the root of the output folder is a map `MessageTypes.txt` with in csv syntax, that contains all discovered proto messages and an index per message. This is useful because the protobuf messages aren't self identifying.

```CSV
0,Test
1,Test.InnerTest
2,Test.InnerTest2
3,Test.InnerTest.InnerInnerTest
```

## Tested

The script was currently tested with following configurations:

 * Ubuntu 13.10: C++, Java, Python
 * Windows 8: C++, Java, Python, C#

## TODO

 * improve documentation
 * refactor some methods and use classes
 * all classes should be in one folder, if possible in one file
 * check input and output paths before (trailing slashes)
