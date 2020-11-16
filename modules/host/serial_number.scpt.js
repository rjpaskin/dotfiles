"use strict";

ObjC.import("IOKit");

(function() {
  function fail(message) {
    console.log("ERR: " + message); // prints to stderr
    $.exit(1);
  }

  var platformExpert = $.IOServiceGetMatchingService(
    $.kIOMasterPortDefault,
    $.IOServiceMatching("IOPlatformExpertDevice")
  );

  if (platformExpert <= 0) fail("Could not get platformExpert");

  var serialNumber = $.IORegistryEntryCreateCFProperty(
    platformExpert,
    $.kIOPlatformSerialNumberKey,
    $.kCFAllocatorDefault,
    0 // "options", currently unused
  ).js;

  $.IOObjectRelease(platformExpert);

  return serialNumber; // will be printed to stdout
})();
