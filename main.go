package main

import (
	"fmt"
	"log"
	"net/http"
	"time"
)

func main() {
	mux := http.NewServeMux()

	mux.HandleFunc("/", func(w http.ResponseWriter, req *http.Request) {
		if req.URL.Path != "/" {
			http.NotFound(w, req)
			return
		}
		_, err := fmt.Fprintf(w, "TEST1234567")
		if err != nil {
			log.Println("error writing response:", err)
		}
	})

	server := &http.Server{
		Addr:         ":5500",
		Handler:      mux,
		ReadTimeout:  10 * time.Second,
		WriteTimeout: 10 * time.Second,
		IdleTimeout:  60 * time.Second,
	}

	log.Println("Starting server on :5500")
	err := server.ListenAndServe()
	if err != nil {
		log.Println(err)
	}
}
