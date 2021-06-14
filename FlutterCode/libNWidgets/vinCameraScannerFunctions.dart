
Future<List<dynamic>> cropImageForVin({@required File plateImage, @required Size size})async{

    // crop image, read text image from image and return croped image with string result text
  String tempDir = (await getTemporaryDirectory()).path;
  String tempPath = '$tempDir/${DateTime.now().toString().split(' ').join('-')}.png';
  var imageBytes = plateImage.readAsBytesSync();
  imglib.Image image = imglib.decodeImage(imageBytes);

  imglib.Image rotateImage = imglib.bakeOrientation(image);
  int x = ((rotateImage.width / 2) - size.width * 0.51).toInt();
  int y = ((rotateImage.height / 2) - (rotateImage.height * 0.05)).toInt();

  double width = (rotateImage.width-(x+x)).toDouble()+10;
  double height = rotateImage.height * 0.1;
  imglib.Image imgCenterCrop = imglib.copyCrop(rotateImage, x, y, width.toInt(), height.toInt());
  File finalImage = File(tempPath)..writeAsBytesSync(imglib.encodePng(imgCenterCrop));

  String scanResultText = await getTextValueFromImage(finalImage, size);

  return [finalImage,scanResultText];
}

Future<String> getTextValueFromImage(File selectedFile,Size size)async{
  try{
    final inputImage = InputImage.fromFilePath(selectedFile.path);
    final textDetector = GoogleMlKit.vision.textDetector();
    final RecognisedText recognisedText = await textDetector.processImage(inputImage);
    textDetector.close();

    List<String> vinTextList=recognisedText.text.split(' ');
 
    vinTextList.sort((a,b)=>a.length.compareTo(b.length));
   
    RegExp regex = RegExp(r'[^a-zA-Z0-9 ]');
    String trimText = vinTextList.last.replaceAll(regex, '');
    if(trimText.trim().length>17){
      return trimText.substring(0,16);
    }
    return trimText;


  }catch(e){
    print('Error:${e.toString()}');
    return null;
  }

}