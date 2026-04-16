package main

import (
	"fmt"
	"golang.org/x/crypto/bcrypt"
)

func main() {
	hash := "$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi"
	
	passwords := []string{"password", "password123", "Admin@12345", "123456"}
	
	for _, p := range passwords {
		err := bcrypt.CompareHashAndPassword([]byte(hash), []byte(p))
		if err == nil {
			fmt.Printf("MATCH FOUND: '%s'\n", p)
		} else {
			fmt.Printf("No match for: '%s'\n", p)
		}
	}
}
