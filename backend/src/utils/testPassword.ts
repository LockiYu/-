/*
 * @Author: test abc@163.com
 * @Date: 2024-12-08 23:50:22
 * @LastEditors: test abc@163.com
 * @LastEditTime: 2024-12-08 23:52:08
 * @FilePath: \Graduation Design Management System\backend\src\utils\testPassword.ts
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
import * as bcrypt from 'bcryptjs';

const password = 'xinxi2024';

async function test() {
    // 生成新的哈希值
    const hash = await bcrypt.hash(password, 10);
    console.log('New hash:', hash);

    // 验证密码
    const isValid = await bcrypt.compare(password, hash);
    console.log('Password valid:', isValid);

    // 生成 SQL
    console.log('\nSQL to update database:');
    console.log(`UPDATE users SET password = '${hash}' WHERE username = '系统管理员';`);
}

test().catch(console.error); 