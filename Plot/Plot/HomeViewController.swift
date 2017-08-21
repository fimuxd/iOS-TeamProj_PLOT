//
//  HomeViewController.swift
//  Plot
//
//  Created by joe on 2017. 7. 31..
//  Copyright © 2017년 joe. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, customCellDelegate {
    
    /*******************************************/
    // MARK: -  Outlet                         //
    /*******************************************/
    
    @IBOutlet weak var mainTableView: UITableView!
    
    let exhibitionDatasRef = Database.database().reference().child("ExhibitionData")
    var exhibitionDataCount:Int = 0
    
    /*******************************************/
    // MARK: -  Life Cycle                     //
    /*******************************************/
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.mainTableView.register(UINib.init(nibName: "MainCustomCell", bundle: nil), forCellReuseIdentifier: "mainCustomCell")
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presentLoginVC()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadmainTabelview), name: NSNotification.Name("dismissPopup"), object: nil)
        
        //--보영: 전시 데이터 가져오고 실시간 반영하기
        exhibitionDatasRef.keepSynced(true)
        
        self.exhibitionDatasRef.observeSingleEvent(of: .value, with: { (snapshot) in
            self.exhibitionDataCount = Int(snapshot.childrenCount)
            
            self.mainTableView.reloadData()
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        self.exhibitionDatasRef.observe(.childChanged, with: { (snapshot) in
            self.exhibitionDataCount = Int(snapshot.childrenCount)
            self.mainTableView.reloadData()
        }) { (error) in
            print(error.localizedDescription)
        }
        
        //좋아요
        Database.database().reference().child("Likes").keepSynced(true)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /*******************************************/
    // MARK: -  CustomCell Delegate Method     //
    /*******************************************/
    
    func isStarPointButtonClicked() {
        presentStarPointPopup()
    }
    
    func isCommentButtonClicked() {
        presentCommentPopup()
    }
    
    func isLikeButtonClicked() {
        self.mainTableView.reloadData()
    }
    
    
    
    /*******************************************/
    // MARK: -  Table View                     //
    /*******************************************/
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:MainCustomCell = tableView.dequeueReusableCell(withIdentifier: "mainCustomCell", for: indexPath) as! MainCustomCell
        
        cell.delegate = self
        
        cell.loadData(RowOfIndexPath: indexPath.row)
        /*
        var selectedExhibitionData:ExhibitionData?{
            didSet{
                guard let realExhibitionData = selectedExhibitionData else {
                    print("리얼데이터가 없습니다")
                    return
                }
                
                cell.mainTitleLabel.text = realExhibitionData.title
                cell.localLabel.text = realExhibitionData.district.rawValue
                cell.exhibitionTerm.text = "\(realExhibitionData.periodData[0].startDate)~\(realExhibitionData.periodData[0].endDate)"
                cell.museumName.text = realExhibitionData.placeData[0].address
                
                cell.indexPathRow = indexPath.row
                
                guard let url = URL(string: realExhibitionData.imgURL[0].posterURL) else {return}
                
                do{
                    let realData = try Data(contentsOf: url)
                    cell.mainPosterImg.image = UIImage(data: realData)
                }catch{
                    
                }
                
                print("여기?")
            }
        }

        DataCenter.sharedData.requestExhibitionData(id: indexPath.row) { (dic) in
            selectedExhibitionData = dic
        }
        
        
        var userLikesData:[(key: String, value: [String : Any])]? {
            didSet{
                guard let realLikeData = userLikesData else {return}
                
                if realLikeData.count != 0 {
                    let exhibitionID:Int = realLikeData[0].value[Constants.likes_ExhibitionID] as! Int
                    if exhibitionID == indexPath.row {
                        cell.likeBtnOutlet.image = #imageLiteral(resourceName: "likeBtn_on")
                    }
                }else{
                    cell.likeBtnOutlet.image = #imageLiteral(resourceName: "likeBtn_off")
                }
                
                self.mainTableView.reloadData()
                print("저기")
            }
        }
        
        DataCenter.sharedData.requestLikeDataFor(exhibitionID: indexPath.row, userID: Auth.auth().currentUser?.uid, completion: { (datas) in
            userLikesData = datas
        })
        */
        
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.exhibitionDataCount
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 174
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailViewController:DetailViewController = storyboard?.instantiateViewController(withIdentifier: "detailViewController") as! DetailViewController
        detailViewController.exhibitionID = indexPath.row
        self.navigationController?.pushViewController(detailViewController, animated: true)
    }
    
    
    /*******************************************/
    // MARK: - Func                            //
    /*******************************************/
    
    func presentLoginVC(){
        if Auth.auth().currentUser == nil {
            let loginVC:LoginViewController = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            present(loginVC, animated: true, completion: nil)
        }else{
            print(Auth.auth().currentUser?.email)
        }
    }
    
    func reloadmainTabelview(){
        print("메인테이블뷰 리로드")
        self.mainTableView.reloadData()
    }
    
    
    func presentCommentPopup(){
        let popup = storyboard?.instantiateViewController(withIdentifier: "Popup") as! Popup
        present(popup, animated: true, completion: nil)
    }
    
    func presentStarPointPopup(){
        let popup = storyboard?.instantiateViewController(withIdentifier: "StarPointPopup") as! StarPointPopupViewController
        present(popup, animated: true, completion: nil)
        
    }
    
    
}
