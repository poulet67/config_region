-- put config_region in your Saved Games/Scripts folder

package.path = package.path .. ";" .. lfs.writedir() .. "Scripts\\?.lua;"
require("config_region")