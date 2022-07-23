//
//  ContentView.swift
//  Toon1_220701
//
//  Created by Amit Gupta on 7/3/22.
//


import SwiftUI
import Alamofire
import SwiftyJSON

struct ContentView: View {
    @State var userMessage = " "
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage? = UIImage(named: "paws")
    @State private var toonified=false
    @State private var buttonText="Make me an AI expert"
    @State private var buttonImage="IloveAI"

    var body: some View {

            VStack (alignment: .center,
                    spacing: 5){
                Image("newTopBar")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height:100)

                //Text(userMessage)
                if toonified {
                    Image(uiImage: inputImage!).resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height:400)
                        .clipShape(Circle())
                } else {
                    Image(uiImage: inputImage!).resizable()
                        .aspectRatio(contentMode: .fill)
                }
                button2
                Spacer()
        }.sheet(isPresented: $showingImagePicker, onDismiss: processImage) {
            ImagePicker(image: self.$inputImage)
        }
        .background(Color.blue)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    var buttonOriginal : some View {
        Button(action:{
            self.buttonPressed()
        }) {
            Image(buttonImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
        }
        .padding(.all, 10.0)
        .font(.system(size: 40))
        .foregroundColor(.white)
        .background(Color.blue)
        .cornerRadius(10)
    }
    
    var button2 : some View {
        Button(action:{
            self.buttonPressed()
        }) {
            HStack{
                Text("I")
                Text("❤️")
                Text("AI")
            }
        }
        .padding(.all, 10.0)
        .font(.system(size: 60))
        .foregroundColor(.white)
        .background(Color.blue)
        .cornerRadius(10)
    }
    
    func buttonPressed() {
        print("Button pressed")
        self.showingImagePicker = true
    }
    
    func processImage() {
        self.showingImagePicker = false
        self.userMessage="Checking..."
        guard let inputImage = inputImage else {return}
        print("Processing image due to Button press")
        let imageSaver = ImageSaver()
        imageSaver.writeToPhotoAlbum(image: inputImage)
        
        let imageJPG=inputImage.jpegData(compressionQuality: 0.0034)!


        
        let toonifyURL="https://api.deepai.org/api/toonify"
        //let toonifyURL="https://httpbin.org/post"
        let toonifyApiKey="291ddfa7-f75c-4d3b-8015-2c3803953814"
        submitImage(imageJPG,toonifyURL,toonifyApiKey)
        
    }
    
    func submitImage(_ imageJPG:Data, _ toonURL:String, _ apiKey:String) {
        print("In submit Image")
        let headers: HTTPHeaders = [
            "api-key": apiKey,
            "Accept": "application/json"
        ]
        AF.upload(multipartFormData: { multiPart in
            multiPart.append(imageJPG, withName: "image", fileName:"file.jpeg",
                             mimeType: "image/jpeg")
            
        },
                  to: toonURL, method: .post, headers: headers).responseJSON { response in
            
            debugPrint(response)
            switch response.result {
            case .success(let responseJsonStr):
                print("\n\n Success value and JSON: \(responseJsonStr)")
                let myJson = JSON(responseJsonStr)
                guard let newUrl=myJson["output_url"].string else {
                    // Handle error case correctly
                    print("Unhandled exception")
                    self.userMessage="Please re-try!!"
                    return
                }
                self.userMessage="One minute..."
                downloadToon(newUrl)
                
                
            case .failure(let error):
                print("\n\n Request failed with error: \(error)")
            }
        }
        print("Normal exit after AF Upload; return handled in closure")
        
    }
    
    func downloadToon(_ toonUrl: String) {
        AF.request(toonUrl).responseData { (response) in
            if response.error == nil {
                print(response.result)
                
                // Show the downloaded image:
                if let data = response.data {
                    self.inputImage = UIImage(data: data)
                    toonified=true
                    self.userMessage=""
                    self.buttonText="I'm an AI expert"
                    let imageSaver = ImageSaver()
                        imageSaver.writeToPhotoAlbum(image: inputImage!)
                    let image2 = body.snapshot()
                    UIImageWriteToSavedPhotosAlbum(image2, nil, nil, nil)
                }
            }
        }
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var image: UIImage?
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
//        picker.sourceType = .camera
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
