/*
 * @Author: test abc@163.com
 * @Date: 2024-12-09 12:08:43
 * @LastEditors: test abc@163.com
 * @LastEditTime: 2024-12-09 12:10:38
 * @FilePath: \Graduation Design Management System\backend\generateHash.ts
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
import * as bcrypt from 'bcryptjs'

const password = '123456'
bcrypt.genSalt(10).then(salt => {
    bcrypt.hash(password, salt).then(hash => {
        console.log('Password hash for 123456:', hash)
    })
})

