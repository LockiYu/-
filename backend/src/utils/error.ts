import { Response } from 'express'

export const handleError = (res: Response, error: any) => {
  console.error('Error:', error)
  res.status(500).json({
    code: 500,
    message: '服务器内部错误',
    error: process.env.NODE_ENV === 'development' ? error.message : undefined
  })
} 