package main

import (
	"log"
	"net/http"

	"github.com/labstack/echo/v4"
)

func main() {
	e := echo.New()

	e.GET("/", hello)
	e.GET("/health", health)

	if err := e.Start(":8080"); err != nil {
		log.Fatal(err.Error())
	}
}

func health(c echo.Context) error {
	return c.NoContent(http.StatusNoContent)
}

func hello(c echo.Context) error {
	return c.String(http.StatusOK, "Hello, World!")
}
