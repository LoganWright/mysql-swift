//
//  MySQLTests.swift
//  MySQLTests
//
//  Created by ito on 2015/10/24.
//  Copyright © 2015年 Yusuke Ito. All rights reserved.
//

import XCTest
@testable import MySQL

/*
// You need `Constants.swift` includes `TestConstants`

struct TestConstants: TestConstantsType {
    let host: String = ""
    let port: Int = 3306
    let user: String = ""
    let password: String = ""
    let database: String = "test"
    let tableName: String = "unit_test_db_3894"
    let timeZone: Connection.TimeZone = Connection.TimeZone(GMTOffset: 60 * 60 * 9) // JST
}

*/

protocol TestConstantsType: ConnectionOption {
    var tableName: String { get }
}


class MySQLTests: XCTestCase {
    
    var constants: TestConstantsType!
    var pool: ConnectionPool!
    
    override func setUp() {
        super.setUp()
        
        self.constants = TestConstants()
        self.pool = ConnectionPool(options: constants)
        
        XCTAssertEqual(constants.timeZone, Connection.TimeZone(GMTOffset: 60 * 60 * 9) )
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
}
