import * as fs from 'fs'
import bcrypt from 'bcryptjs'

const departments = ['计算机系', '软件工程系', '信息安全系', '人工智能系', '数据科学系']
const majors = ['计算机科学与技术', '软件工程', '信息安全', '人工智能', '数据科学']
const titles = ['教授', '副教授', '讲师', '助教']
const names = ['张', '李', '王', '刘', '陈', '杨', '赵', '黄', '周', '吴']
const secondNames = ['伟', '芳', '娜', '秀英', '敏', '静', '丽', '强', '磊', '洋']

function generatePhone() {
    return `139${Math.floor(Math.random() * 100000000).toString().padStart(8, '0')}`
}

function generateEmail(username: string) {
    return `${username}@test.com`
}

async function generateUsers() {
    const password = await bcrypt.hash('123456', 10)
    let users = []

    // 生成系统管理员
    for (let i = 1; i <= 2; i++) {
        users.push({
            user_id: `SA2024${i.toString().padStart(3, '0')}`,
            username: `admin${i}`,
            password,
            role: 'superadmin',
            name: `管理员${i}`,
            department: '系统部',
            title: '高级管理员'
        })
    }

    // 生成管理员
    for (let i = 1; i <= 8; i++) {
        users.push({
            user_id: `A2024${i.toString().padStart(3, '0')}`,
            username: `manager${i}`,
            password,
            role: 'admin',
            name: `${names[i % 10]}${secondNames[i % 10]}`,
            department: departments[i % departments.length],
            title: '部门主管'
        })
    }

    // 生成教师
    for (let i = 1; i <= 30; i++) {
        users.push({
            user_id: `T2024${i.toString().padStart(3, '0')}`,
            username: `teacher${i}`,
            password,
            role: 'teacher',
            name: `${names[i % 10]}${secondNames[i % 10]}`,
            department: departments[i % departments.length],
            title: titles[i % titles.length]
        })
    }

    // 生成学生
    for (let i = 1; i <= 50; i++) {
        users.push({
            user_id: `S2024${i.toString().padStart(3, '0')}`,
            username: `student${i}`,
            password,
            role: 'student',
            name: `${names[i % 10]}${secondNames[i % 10]}`,
            department: departments[i % departments.length],
            major: majors[i % majors.length]
        })
    }

    // 生成访客
    for (let i = 1; i <= 10; i++) {
        users.push({
            user_id: `G2024${i.toString().padStart(3, '0')}`,
            username: `guest${i}`,
            password,
            role: 'guest',
            name: `访客${i}`,
            department: '外部单位'
        })
    }

    // 生成 SQL 语句
    let sql = 'INSERT INTO users (user_id, username, password, role, email, name, gender, department, major, title, phone, introduction, status) VALUES\n'

    sql += users.map(user => `(
    '${user.user_id}',
    '${user.username}',
    '${password}',
    '${user.role}',
    '${generateEmail(user.username)}',
    '${user.name}',
    '${Math.random() > 0.5 ? 'male' : 'female'}',
    '${user.department}',
    ${user.major ? `'${user.major}'` : 'NULL'},
    ${user.title ? `'${user.title}'` : 'NULL'},
    '${generatePhone()}',
    '${user.name}的个人简介',
    'active'
  )`).join(',\n')

    sql += ';'

    fs.writeFileSync('insert_users.sql', sql)
}

generateUsers()