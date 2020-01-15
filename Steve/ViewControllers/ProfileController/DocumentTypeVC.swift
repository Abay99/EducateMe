//
//  CategoryVC.swift
//  Steve
//
//  Created by Sudhir Kumar on 06/06/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit
import MobileCoreServices
import Analytics

let kRequestImageName = "steveImage"
let kRequestPDFName = "pdfDocuments.pdf"
let kSourceValueKey = "resource"
let kContentImageType   = "image/jpeg"
let kContentPDFType = "application/pdf"

typealias documentVCHandler = (_ status:Bool , _ doc:Document?) -> Void

class DocumentTypeVC: UIViewController,documentCellDelegate,UIDocumentPickerDelegate {
    
    // IBOutlets
    @IBOutlet weak var topView: TopBarView!
    @IBOutlet weak var categoryTableView: UITableView!
    @IBOutlet weak var saveButton: UIButton!
    
    // Variables
    var isExpanded:Bool = false
    var selectedSection = -1
    var documentData:[Document]?
    var selectedIds:[Int] = []
    var isViewOnly:Bool = false
    var complition:(([Int])->Void)?
    var selectedDocInfo:Document?
    var handler:documentVCHandler?
    var user:User?
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
        SEGAnalytics.shared().screen(AnalyticsScreens.documentIdentityVC)
        self.setupTopView()
        self.setupUI()
        self.getDocumentTypeList()
        categoryTableView.isHidden = true
        //UserManager.shared.deleteUserUploadedDoc()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Custom Method
    private func setupTopView() {
        if self.isViewOnly {
            // self.topView.setHeaderData(title: NavTitle.Identity_Documents, leftButtonImage: AppImage.backButton, rightButtonImage: AppImage.editIcon)
            self.topView.setHeaderData(title: NavTitle.Identity_Documents, leftButtonImage: AppImage.backButton)
        } else {
            self.topView.setHeaderData(title: NavTitle.Identity_Documents, leftButtonImage: AppImage.backButton)
        }
        self.topView.dropShadow(shadowOffset: CGSize(width: 0, height: 5) , radius: 8, color: CustomColor.profileShadowColor, shadowOpacity: 0.7)
        self.topView.delegate = self
    }
    
    private func setupUI() {
        self.categoryTableView.estimatedRowHeight = 50
        self.categoryTableView.rowHeight = UITableViewAutomaticDimension
        self.categoryTableView.dataSource = self
        self.categoryTableView.delegate = self
        if self.isViewOnly {
            //showMyProfile()
        }
    }
    
    private func setupData() {
        self.categoryTableView.reloadData()
        categoryTableView.isHidden = false
    }
    
    func documentHandlerSetup(handler:@escaping documentVCHandler)  {
        self.handler = handler
    }
    
    // MARK: - IBActions
    @IBAction func saveClicked() {
        saveData()
        if let _ = handler {
            handler!(true, nil);
        }
        UserManager.shared.saveDocEditingStatus()
        self.dismiss(animated: true, completion: nil)
    }
    
    private func saveData() {
        
        var documents:[[String:String]] = []
        //var docPrams =
        for doc in documentData! {
            if doc.image != nil {
                let params  = ["docType":doc.docType , "image":doc.image ,"imageUrl":doc.imageUrl]
                if params is [String : String] {
                    documents.append(params as! [String : String]);
                }
            }
        }
        UserManager.shared.saveUserUploadedDoc(docs: documents);
    }
    
    func documentPlusCellButtonTap(info:Document) {
        selectedDocInfo = info;
        //openImageGalleryOrCamera(openGallery: true)
        chooseImageFrom()
    }
    
    func documentRemoveCellButtonTap(info:Document) {
        
//        if let index = self.documentData?.indexOf({$0.id == info.id}) {
//            //self.user?.userDocuments?.remove(at: index)
//
//        }
        if let _ = handler {
            handler!(true,info);
        }
        
        if isViewOnly == false {
            selectedDocInfo = info;
            deleteDocument(doc: info)
        }
        else {
            if let index = self.documentData?.indexOf({$0.id == info.id}) {
                self.documentData![index].image = nil
                self.documentData![index].resourceId = nil
                self.documentData![index].docType = nil
                self.documentData![index].imageUrl = nil
                categoryTableView.reloadData()
            }
        }
    }
    
    func viewDocumentTap(info:Document) {
        let imageViewVC = UIStoryboard.navigateToDocImageVC()
        imageViewVC.imageUrl = info.imageUrl
        imageViewVC.docName = info.documentName
        self.present(imageViewVC, animated: true, completion:nil )
    }
}

extension DocumentTypeVC:UITableViewDataSource, UITableViewDelegate {
    // MARK: - Table Datasource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (documentData?.count) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "DocumentTypeCell", for: indexPath) as? DocumentTypeCell {
            cell.setUpData(info: documentData![indexPath.row])
            cell.delegate = self
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}

extension DocumentTypeVC:TopBarViewDelegate {
    // MARK: - TopBarDelegate
    func didTapLeftButton() {
        self.dismiss(animated: true) {}
        //UserManager.shared.deleteUserUploadedDoc()
    }
    
    func didTapRightButton(_ btn: UIButton?) {
        
    }

}

extension DocumentTypeVC {
    // MARK: - Web services
    func getDocumentTypeList() {
        self.view.showLoader()
        DataManager.shared.getDocuemntType { (lists, _, error) in
            self.view.hideLoader()
            if error == nil {
                guard let document = lists else { return }
                self.documentData = document
                self.setupData()
                if self.isViewOnly {
                    self.showMyProfile()
                }
                else {
                    if let savedParams = UserManager.shared.getUserUploadedDoc() {
                        for param in savedParams {
                            if  let docType = param["docType"] {

                                if let index = self.documentData?.indexOf({$0.id == Int(docType)}) {
                                    self.documentData![index].image = param["image"]
                                    self.documentData![index].docType = docType
                                    self.documentData![index].imageUrl = param["imageUrl"]
                                }

                            }
                        }
                    }
                    self.categoryTableView.reloadData()
                }
            }
            else {
                TopMessage.shared.showMessageWithText(text: error?.localizedDescription ?? "", completion: nil)
            }
        }
    }
    
    private func showMyProfile() {
        self.view.showLoader()
        DataManager.shared.showProfile { (userData, _, error, status) in
            self.view.hideLoader()
            if error == nil {
                if userData != nil {
                    for doc in self.user?.userDocuments ?? [] {
                        let type = String(describing: doc.docType!)
                        if let index = self.documentData?.indexOf({$0.id == doc.docType}) {
                            self.documentData![index].image = doc.image;
                            self.documentData![index].docType = type
                            self.documentData![index].imageUrl = doc.imageUrl;
                        }
                    }
                }
                
                if let savedParams = UserManager.shared.getUserUploadedDoc() {
                    for param in savedParams {
                        if  let docType = param["docType"] {
                            
                            if let index = self.documentData?.indexOf({$0.id == Int(docType)}) {
                                self.documentData![index].image = param["image"]
                                self.documentData![index].docType = docType
                                self.documentData![index].imageUrl = param["imageUrl"]
                            }
                            
                        }
                    }
                }
                
                self.categoryTableView.reloadData()
            } else {
                TopMessage.shared.showMessageWithText(text: error?.localizedDescription ?? "", completion: nil)
            }
        }
    }
    
    func uploadPDFDoc(data:Data) {
        
        var fileParams:[String:AnyObject] = [String:AnyObject]()
        fileParams[MultiPartKey.kFileNameKey] = kRequestPDFName as AnyObject?
        fileParams[MultiPartKey.kSourceKey] = "imageUrl" as AnyObject?
        fileParams[MultiPartKey.kValueKey] = data as AnyObject
        fileParams[MultiPartKey.kContentTypeKey] = kContentPDFType as AnyObject?
        fileParams[MultiPartKey.kmimeTypeKey] = kContentPDFType as AnyObject?
        var dataFiled = [String:String]()
        let id = String.init(selectedDocInfo?.id ?? 0)
        dataFiled.updateValue(id, forKey: "docType")
        //uploadDocToServer(fileParams: fileParams, dataField: dataFiled)
        
        if let index = self.documentData?.indexOf({$0.id == self.selectedDocInfo?.id}) {
            categoryTableView.reloadData()
            self.documentData![index].isUploadingProgress = true
            self.categoryTableView.reloadData()
            self.documentData![index].uploadPDFDoc(data: data){ (status,obj, error) in
                self.categoryTableView.reloadData()
            }
        }
    }
    
    
    func uploadDoc(image:UIImage) {
        
        var fileParams:[String:AnyObject] = [String:AnyObject]()
        //if let data:Data = UIImagePNGRepresentation(image) {
        if let data:Data = UIImageJPEGRepresentation(image, 0.5){
            fileParams[MultiPartKey.kFileNameKey] = kRequestImageName as AnyObject?
            fileParams[MultiPartKey.kSourceKey] = "imageUrl" as AnyObject?
            fileParams[MultiPartKey.kValueKey] = data as AnyObject
            fileParams[MultiPartKey.kContentTypeKey] = kContentImageType as AnyObject?
            
            var dataFiled = [String:String]()
            let id = String.init(selectedDocInfo?.id ?? 0)
            dataFiled.updateValue(id, forKey: "docType")
            
            if let index = self.documentData?.indexOf({$0.id == self.selectedDocInfo?.id}) {
                categoryTableView.reloadData()
                self.documentData![index].isUploadingProgress = true
                self.categoryTableView.reloadData()
                self.documentData![index].uploadDoc(image: image) { (status,obj, error) in
                    self.categoryTableView.reloadData()
                }
            }
        }
        
        //uploadDocToServer(fileParams: fileParams, dataField: dataFiled as [String : String])
    }
    
    func uploadDocToServer(fileParams:[String:AnyObject] , dataField:[String:String]) {
        self.view.showLoader()
        DataManager.shared.uploadUserDocWithUploadTask(fileParams, dataField: dataField, completion: { (success, error, obj) -> (Void) in
            self.view.hideLoader()
            if success == true {
                if let index = self.documentData?.indexOf({$0.id == self.selectedDocInfo?.id}) {
                    self.documentData![index].image = obj?.image;
                    self.documentData![index].resourceId = obj?.resourceId;
                    self.documentData![index].docType = obj?.docType;
                    self.documentData![index].imageUrl = obj?.imageUrl;
                }
                self.categoryTableView.reloadData()
            }
            else {
                TopMessage.shared.showMessageWithText(text: error?.localizedDescription ?? "", completion: nil)
            }
        })
    }
    
    func deleteDocument(doc:Document) {
        
        let params = ["docType":doc.docType,"image":doc.image]
        self.view.showLoader()
        DataManager.shared.deleteDocuemnt(Params: params as [String : AnyObject]) { ( status, error) in
            self.view.hideLoader()
            if status == true {
                if let index = self.documentData?.indexOf({$0.id == doc.id}) {
                    self.documentData![index].image = nil
                    self.documentData![index].resourceId = nil
                    self.documentData![index].docType = nil
                    self.documentData![index].imageUrl = nil
                }
               
                self.categoryTableView.reloadData()
            }
            else {
                TopMessage.shared.showMessageWithText(text: error?.localizedDescription ?? "", completion: nil)
            }
        }
    }
}

extension DocumentTypeVC {
    //MARK: - ImagePicker
    func chooseImageFrom() {
        /* Open Action Sheet for Image */
        Utilities.openActionSheetWith(arrOptions:["Add photo from gallery", "Take a new photo" , "Others"],openIn: self) { actionIndex in
            //Utilities.openActionSheetWith(openIn: self) { actionIndex in
            switch actionIndex {
            case 0: // Add photo from gallery
                self.openImageGalleryOrCamera(openGallery: true)
                break
            case 1: // Take a new photo
                self.openImageGalleryOrCamera(openGallery: false)
                break
            case 2: // Take a new photo
                self.openDocumentPicker()
                break
            default:
                self.openImageGalleryOrCamera(openGallery: true)
                break
            }
        }
    }
    
    override func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        dismiss(animated: true, completion: {
            if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
                self.uploadDoc(image: image)
            }
        })
    }
    
    /* Open Image Gallery or Camera as per user selection */
    func openImageGalleryOrCamera(openGallery: Bool) {
        let picker: UIImagePickerController? = UIImagePickerController()
        picker?.delegate = self
        picker!.sourceType = openGallery ? .photoLibrary : UIImagePickerController.isSourceTypeAvailable(.camera) ? .camera : .photoLibrary
        picker?.allowsEditing = true
        present(picker!, animated: true, completion: nil)
    }
    
    func openDocumentPicker() {
        let types: [String] = [kUTTypePDF as String]
        let documentPicker = UIDocumentPickerViewController(documentTypes: types, in: .import)
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .formSheet
        self.present(documentPicker, animated: true, completion: nil)
    }
    
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        let myURL = url as URL
        
        do {
            let data = try Data(contentsOf: myURL)
            // do something with data
            // if the call fails, the catch block is executed
            self.uploadPDFDoc(data: data)
        } catch {
            print(error.localizedDescription)
        }
        print("import result : \(myURL)")
        
    }
    
    public func documentMenu(_ documentMenu:UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("view was cancelled")
        //dismiss(animated: true, completion: nil)
    }
}
