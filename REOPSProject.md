# REOPS Flash Builder Project #

  * The OSMF\_ReleaseSamples project was developed using the OSMF source checked out from the [public SVN](http://opensource.adobe.com/wiki/display/osmf/Get+Source+Code) and referenced from the same FlashBuilder workspace. This was done so Ctrl+[CLASS NAME](CLICK.md) code insight quick linking could be used.
    * Link the OSMF source via the Main Menu -> Project -> Properties > ActionScript Build Path > Library Path > Add Project. Select the OSMF project.
  * The target Flash player is 10.1, with the Flex 4.0 release SDK (
    * You will need to remove the OSMF SWC that is currently provided with the Flex 4.0 SDK
      * Project Properties -> ActionScript Build Path-> Expand the Flex 4.0 list item
      * Select the osmf.swc and click the remove button
  * Add the following compiler arguments:
    * `CONFIG::LOGGING`
    * `CONFIG::FLASH_10_1`
    * In the project properties -> ActionScript Compiler -> Additional compiler arguments add: `-define CONFIG::LOGGING true -define CONFIG::FLASH_10_1 true`