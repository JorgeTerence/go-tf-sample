package main

import (
	"github.com/gin-gonic/gin"
	"net/http"
)

type Article struct {
	Title   string
	Content string
	Author  string
}

var (
	users    = make(map[string]string)
	articles = make([]Article, 0, 5)
)

func setupRouter() *gin.Engine {
	r := gin.Default()

	r.GET("/ping", func(c *gin.Context) {
		c.String(http.StatusOK, "pong")
	})

	r.GET("/hello", func(c *gin.Context) {
		c.String(http.StatusOK, "Welcome to AWS, %s", c.Query("name"))
	})

	// Register a new user
	// Example: curl POST http://localhost:8080/user/MyUserName -d "password=MyFavouriteCartoon"
	r.POST("/user/:name", func(c *gin.Context) {
		user := c.Params.ByName("name")
		password := c.PostForm("password")
		users[user] = password
		c.String(http.StatusOK, "Welcome, %s", user)
	})

	// Write a new article
	// Example: curl -u username:password -X POST http://localhost:8080/article -d "title=MyTitle&content=MyContent"
	r.POST("/article", func(c *gin.Context) {
		user, password, ok := c.Request.BasicAuth()
		savedPassword, userOk := users[user]

		if !ok || !userOk || savedPassword != password {
			c.String(http.StatusUnauthorized, "Authorization failed")
			return
		}

		article := Article{c.PostForm("title"), c.PostForm("content"), user}
		articles = append(articles, article)

		c.JSON(http.StatusOK, gin.H{"status": "ok"})
	})

	r.GET("/article/:title", func(c *gin.Context) {
		title := c.Params.ByName("title")
		for _, article := range articles {
			if article.Title == title {
				c.JSON(http.StatusOK, article)
				return
			}
		}

		c.JSON(http.StatusNotFound, gin.H{"status": "not found"})
	})

	return r
}

func main() {
	r := setupRouter()
	r.Run(":8000")
}
