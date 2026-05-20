use std::env;
use std::fs::File; // For read_file_lines()
use std::io::{self, BufRead, Read};
use std::process;

fn lines_count(filename: &str) -> Result<usize, io::Error> {
    let file = File::open(filename)?;
    Ok(io::BufReader::new(file).lines().count())
}

fn words_count(filename: &str) -> Result<usize, io::Error> {
    let file = File::open(filename)?;
    let mut buf = String::new();
    io::BufReader::new(file).read_to_string(&mut buf)?;
    Ok(buf.split_whitespace().count())
}

fn chars_count(filename: &str) -> Result<usize, io::Error> {
    let file = File::open(filename)?;
    let mut buf = String::new();
    io::BufReader::new(file).read_to_string(&mut buf)?;
    Ok(buf.chars().count())
}

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() < 2 {
        println!("Too few arguments.");
        process::exit(1);
    }
    let filename = &args[1];

    println!("words count: {}", words_count(filename).unwrap());
    println!("lines count: {}", lines_count(filename).unwrap());
    println!("chars count: {}", chars_count(filename).unwrap());
}
