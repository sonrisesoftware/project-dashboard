mkdir $2.iconset
sips -z 16 16     $1.png --out $2.iconset/icon_16x16.png
sips -z 32 32     $1.png --out $2.iconset/icon_16x16@2x.png
sips -z 32 32     $1.png --out $2.iconset/icon_32x32.png
sips -z 64 64     $1.png --out $2.iconset/icon_32x32@2x.png
sips -z 128 128   $1.png --out $2.iconset/icon_128x128.png
sips -z 256 256   $1.png --out $2.iconset/icon_128x128@2x.png
sips -z 256 256   $1.png --out $2.iconset/icon_256x256.png
sips -z 512 512   $1.png --out $2.iconset/icon_256x256@2x.png
sips -z 512 512   $1.png --out $2.iconset/icon_512x512.png
cp $1.png $2.iconset/icon_512x512@2x.png
iconutil -c icns $2.iconset
rm -R $2.iconset