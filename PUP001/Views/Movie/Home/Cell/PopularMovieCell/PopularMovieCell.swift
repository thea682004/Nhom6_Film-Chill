//
//  PopularMovieCell.swift
//  PUP001
//
//  Created by chuottp on 09/05/2023.
//

import UIKit
import SDWebImage
import CollectionViewPagingLayout

class PopularMovieCell: UICollectionViewCell, StackTransformView {
    
    private var item: ItemMovies?
    private var itemTv: ItemTVShow?
    // private var itemTv: PopularTvShow?
    var checkType: Bool = true
    var getId: ((Int) -> Void)?
    // weak var delegateTv: TvProtocol?
    
    @IBOutlet weak var imgPopularMovie: UIImageView! {
        didSet {
            imgPopularMovie.layer.cornerRadius = 8
            self.imgPopularMovie.isUserInteractionEnabled = true
        }
    }
    
    @objc private func onTap() {
        print("Tap tap: ", item?.id ?? 0)
        self.getId?(item?.id ?? 0)
    }
    
    var stackOptions: StackTransformViewOptions {
        var options = StackTransformViewOptions.layout(.perspective)
        options.blurEffectEnabled = true
        options.blurEffectStyle = .light
        options.spacingFactor = 0.25
        options.alphaFactor = 0
        return options
    }
    
    func configData(item: ItemMovies) {
        self.item = item
        self.imgPopularMovie.loadImage(link: item.posterPath)
        
    }
    func configDataTv(item: ItemTVShow) {
        self.itemTv = item
        self.imgPopularMovie.loadImage(link: item.posterPath)
        
    }

}
