package main

import (
	"fmt"
	"golang.org/x/crypto/bcrypt"
)

func main() {
	pass := "password123"
	hash, _ := bcrypt.GenerateFromPassword([]byte(pass), 10)
	fmt.Println(string(hash))
}
