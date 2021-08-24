//
//  BattleViewController.swift
//  TechMon
//
//  Created by 河村大介 on 2021/08/23.
//

import UIKit

class BattleViewController: UIViewController {
    
    // 自分
    @IBOutlet weak var playerNameLabel: UILabel!
    @IBOutlet weak var playerImageView: UIImageView!
    @IBOutlet weak var playerHPLabel: UILabel!
    @IBOutlet weak var playerMPLabel: UILabel!
    @IBOutlet weak var playerTPLabel: UILabel!
    
    // 敵
    @IBOutlet weak var enemyNameLabel: UILabel!
    @IBOutlet weak var enemyImageView: UIImageView!
    @IBOutlet weak var enemyHPLabel: UILabel!
    @IBOutlet weak var enemyMPLabel: UILabel!
    
    // TechMonManagerのインスタンス化
    let techMonManager: TechMonManager = TechMonManager()
    
    // TechMonManagerからCharacterのインスタンス生成
    var player: Character!
    var enemy: Character!
    
    // ゲームのタイマークラス
    var gameTimer: Timer!
    
    // 勝負が決まった時と初期の段階で攻撃ができないようにするタグ
    var isPlayerAttackAvailable: Bool = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        player = techMonManager.player
        enemy = techMonManager.enemy
        
        // UIに表示
        playerNameLabel.text = player.name
        playerImageView.image = player.image
        enemyNameLabel.text = enemy.name
        enemyImageView.image = enemy.image
        
        //ゲームスタート
        gameTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateGame), userInfo: nil, repeats: true)
        gameTimer.fire()
        
    }
    
    // 0.1秒ごとに繰り返し発火
    @objc func updateGame() {
        // 自分のステータス
        player.currentMP += 1
        if player.currentMP >= 20 {
            isPlayerAttackAvailable = true
            player.currentMP = 20
        } else {
            isPlayerAttackAvailable = false
        }
        
        // 敵のステータス
        enemy.currentMP += 1
        
        if enemy.currentMP >= 35 {
            isPlayerAttackAvailable = true
            enemyAttack()
            enemy.currentMP = 0
        }
        
        updateUI()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        techMonManager.playBGM(fileName: "BGM_battle001")
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        techMonManager.stopBGM()
    }
    
    
    // 敵のアタックポイントが35になったら発火
    func enemyAttack() {        techMonManager.damageAnimation(imageView: playerImageView)
        techMonManager.playSE(fileName: "SE_attack")
        
        player.currentHP -= enemy.attackPoint
        judgeBattle()
        updateUI()
    }
    
    // 自分側の攻撃
    @IBAction func attackAction() {
        if isPlayerAttackAvailable {
            techMonManager.damageAnimation(imageView: enemyImageView)
            techMonManager.playSE(fileName: "SE_attack")
            enemy.currentHP -= player.attackPoint
            
            player.currentTP += 10
            if player.currentTP >= player.maxTP {
                player.currentTP = player.maxTP
            }
            
            player.currentMP = 0
            judgeBattle()
            updateUI()
        }
    }
    
    @IBAction func fireAction() {
        if isPlayerAttackAvailable && player.currentTP >= 40 {
            techMonManager.damageAnimation(imageView: enemyImageView)
            techMonManager.playSE(fileName: "SE_fire")
            
            enemy.currentHP -= 100
            
            player.currentTP -= 40
            
            if player.currentTP <= 0 {
                player.currentTP = 0
            }
            
            player.currentMP = 0
            
            judgeBattle()
            updateUI()
        }
    }
    
    @IBAction func tameruAction() {
        if isPlayerAttackAvailable {
            
            techMonManager.playSE(fileName: "SE_charge")
            player.currentTP += 40
            if player.currentTP >= player.maxTP {
                player.currentTP = player.maxTP
            }
            
            player.currentMP = 0
            
            updateUI()
        }
    }
    
    
    
    // 勝敗が決着した時の処理
    func finishBattle(vanishImageView: UIImageView, isPlayerWin: Bool) {
        techMonManager.vanishAnimation(imageView: vanishImageView)
        techMonManager.stopBGM()
        gameTimer.invalidate()
        isPlayerAttackAvailable = false
        
        
        var finishMessage: String = ""
        
        if isPlayerWin {
            techMonManager.playSE(fileName: "SE_fanfare")
            finishMessage = "勇者の勝利！"
        } else {
            techMonManager.playSE(fileName: "SE_gameover")
            finishMessage = "勇者の敗北..."
        }
        
        let alert: UIAlertController = UIAlertController(title: "バトル終了", message: finishMessage, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    // ステータスを現在のものに変更
    func updateUI() {
        // プレイヤーのステータス反映
        playerHPLabel.text = "\(player.currentHP) / \(player.maxHP)"
        playerMPLabel.text = "\(player.currentMP) / \(player.maxMP)"
        playerTPLabel.text = "\(player.currentTP) / \(player.maxTP)"
        
        // 敵のステータス反映
        enemyHPLabel.text = "\(enemy.currentHP) / \(enemy.maxHP)"
        enemyMPLabel.text = "\(enemy.currentMP) / \(enemy.maxMP)"
    }
    
    // 勝敗判定
    func judgeBattle() {
        
        if player.currentHP <= 0 {
            finishBattle(vanishImageView: playerImageView, isPlayerWin: false)
        } else if enemy.currentHP <= 0 {
            finishBattle(vanishImageView: enemyImageView, isPlayerWin: true)
        }
    }

}
