# Web-to-mobi - A script for converting web sites to mobipcoket format

This script get JSON data about a web site from STDIN and convert web data to mobipcoket format.

JSON data format is like this.

    {
         "title"    : "Getting Real",
         "author"   : "37signals",
         "chapters" : [
             {
                 "title"     : "Introduction",
                  "sections" : [
                      {
                          "title" : "What is Getting Real?",
                          "uri"   : "http://gettingreal.37signals.com/ch01_What_is_Getting_Real.php"
                      },
                      {
                          "title" : "About 37signals",
                          "uri"   : "http://gettingreal.37signals.com/ch01_About_37signals.php"
                      },
                  ]
            }
         ]
         "content_xpath" : "//div[@class=\"content\"]",
         "exclude_xpath" : "//div[@class=\"next\"]"
    }
