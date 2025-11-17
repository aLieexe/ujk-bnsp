package main

import (
	"fmt"
	"log"
	"net/http"
)

func main() {
	mux := http.NewServeMux()

	mux.HandleFunc("/", func(w http.ResponseWriter, req *http.Request) {
		if req.URL.Path != "/" {
			http.NotFound(w, req)
			return
		}

		w.Header().Set("Content-Type", "text/html")
		_, err := fmt.Fprintln(w, `
			<!DOCTYPE html>
			<html>
			<head>
				<title>UJK BNSP</title>
			</head>
			<body>
				<h1>RIZKY ALAY HERMAWAN</h1>
				<p>Deployment pada AWS EC2</p>
			</body>
			</html>
		`)
		if err != nil {
			log.Println("error writing response:", err)
		}
	})

	server := &http.Server{
		Addr:    ":5500",
		Handler: mux,
	}

	log.Println("Starting server on :5500")
	err := server.ListenAndServe()
	if err != nil {
		log.Println(err)
	}
}
