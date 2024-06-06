//
//  GemMatchGameScene.swift
//  GemMatch
//
//  Created by Jigar on 06/06/24.
//

import SwiftUI

import SpriteKit

class GemMatchGameScene: SKScene {
    let numRows = 8
    let numColumns = 8
    let tileSize: CGFloat = 40.0
    
    var tiles = [[SKSpriteNode?]]()
    var selectedTile: SKSpriteNode?
    
    override func didMove(to view: SKView) {
        backgroundColor = .white
        setupTiles()
    }
    
    func setupTiles() {
        for row in 0..<numRows {
            var tileRow = [SKSpriteNode?]()
            for col in 0..<numColumns {
                let tile = SKSpriteNode(color: randomColor(), size: CGSize(width: tileSize, height: tileSize))
                tile.position = CGPoint(x: CGFloat(col) * tileSize + tileSize / 2, y: CGFloat(row) * tileSize + tileSize / 2)
                tile.name = "\(row),\(col)"
                addChild(tile)
                tileRow.append(tile)
            }
            tiles.append(tileRow)
        }
    }
    
    func randomColor() -> UIColor {
        let colors: [UIColor] = [.red, .blue, .green, .yellow, .purple]
        return colors[Int(arc4random_uniform(UInt32(colors.count)))]
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        if let tile = atPoint(location) as? SKSpriteNode {
            selectedTile = tile
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        if let tile = atPoint(location) as? SKSpriteNode, let selectedTile = selectedTile {
            swapTiles(firstTile: selectedTile, secondTile: tile)
            self.selectedTile = nil
        }
    }
    
    func swapTiles(firstTile: SKSpriteNode, secondTile: SKSpriteNode) {
        let firstTilePosition = firstTile.position
        let secondTilePosition = secondTile.position
        
        firstTile.run(SKAction.move(to: secondTilePosition, duration: 0.25)) {
            self.checkForMatches()
        }
        secondTile.run(SKAction.move(to: firstTilePosition, duration: 0.25))
        
        // Update the tiles array
        let firstTileName = firstTile.name!.split(separator: ",").map { Int($0)! }
        let secondTileName = secondTile.name!.split(separator: ",").map { Int($0)! }
        
        tiles[firstTileName[0]][firstTileName[1]] = secondTile
        tiles[secondTileName[0]][secondTileName[1]] = firstTile
        
        firstTile.name = "\(secondTileName[0]),\(secondTileName[1])"
        secondTile.name = "\(firstTileName[0]),\(firstTileName[1])"
    }
    
    func checkForMatches() {
        // Check rows for matches
        for row in 0..<numRows {
            var matchCount = 1
            for col in 1..<numColumns {
                if let currentTile = tiles[row][col], let previousTile = tiles[row][col - 1], currentTile.color == previousTile.color {
                    matchCount += 1
                } else {
                    if matchCount >= 3 {
                        for matchIndex in (col - matchCount)..<col {
                            tiles[row][matchIndex]?.removeFromParent()
                            tiles[row][matchIndex] = nil
                        }
                    }
                    matchCount = 1
                }
            }
            if matchCount >= 3 {
                for matchIndex in (numColumns - matchCount)..<numColumns {
                    tiles[row][matchIndex]?.removeFromParent()
                    tiles[row][matchIndex] = nil
                }
            }
        }
        
        // Check columns for matches
        for col in 0..<numColumns {
            var matchCount = 1
            for row in 1..<numRows {
                if let currentTile = tiles[row][col], let previousTile = tiles[row - 1][col], currentTile.color == previousTile.color {
                    matchCount += 1
                } else {
                    if matchCount >= 3 {
                        for matchIndex in (row - matchCount)..<row {
                            tiles[matchIndex][col]?.removeFromParent()
                            tiles[matchIndex][col] = nil
                        }
                    }
                    matchCount = 1
                }
            }
            if matchCount >= 3 {
                for matchIndex in (numRows - matchCount)..<numRows {
                    tiles[matchIndex][col]?.removeFromParent()
                    tiles[matchIndex][col] = nil
                }
            }
        }
    }
}
