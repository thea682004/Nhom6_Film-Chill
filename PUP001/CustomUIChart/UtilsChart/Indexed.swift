//
//  Indexed.swift
//  PUP001
//
//  Created by chuottp on 21/08/2023.
//


struct Indexed<BaseData: Collection> {
    let base: BaseData
    
    init(base: BaseData) {
        self.base = base
    }
}

extension Indexed: Collection {
    typealias Element = (index: BaseData.Index, element: BaseData.Element)
    
    var startIndex: BaseData.Index {
        base.startIndex
    }
    
    var endIndex: BaseData.Index {
        base.endIndex
    }
    
    subscript(position: BaseData.Index) -> Element {
        (index: position, element: base[position])
    }
    
    func index(after i: BaseData.Index) -> BaseData.Index {
        base.index(after: i)
    }
    
    func index(_ i: BaseData.Index, offsetBy distance: Int) -> BaseData.Index {
        base.index(i, offsetBy: distance)
    }
    
    func index(
        _ i: BaseData.Index,
        offsetBy distance: Int,
        limitedBy limit: BaseData.Index
    ) -> BaseData.Index? {
        base.index(i, offsetBy: distance, limitedBy: limit)
    }
    
    func distance(from start: BaseData.Index, to end: BaseData.Index) -> Int {
        base.distance(from: start, to: end)
    }
    
    var indices: BaseData.Indices {
        base.indices
    }
}

extension Collection {
    func indexed() -> Indexed<Self> {
        Indexed(base: self)
    }
}
