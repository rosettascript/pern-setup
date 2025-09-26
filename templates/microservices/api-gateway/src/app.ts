import express from 'express'

const app = express()
const PORT = process.env.PORT || 5000

app.use(express.json())

app.get('/api/health', (req, res) => {
  res.json({ message: 'API Gateway is running!' })
})

app.listen(PORT, () => {
  console.log(`API Gateway running on port ${PORT}`)
})

export default app




