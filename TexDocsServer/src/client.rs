use std::io::prelude::*;
use std::net::TcpStream;
use std::thread;

static NTHREADS: i32 = 30;

fn main() {

    for i in 0..NTHREADS {

        let _ = thread::spawn(move|| {

            let mut stream = TcpStream::connect("127.0.0.1:8000").unwrap();

            for j in 0..30 {
                if i == NTHREADS-1 {
                    write!(stream, "the answer is {}", j).unwrap();
                }

                let mut r = [0u8; 256];
                match stream.read(&mut r) {
                    Ok(0) => {
                        println!("thread {}: 0 bytes read", i);
                    },
                    Ok(n) => {

                        let s = std::str::from_utf8(&r[..]).unwrap();
                        println!("thread {}: {} bytes read  \t\t {}", i, n, s);
                        // println!("thread {} read = {}", i, s);
                    },
                    Err(e) => {
                        panic!("thread {}: {}", i, e);
                    }
                }
            }
        });
    }

    loop {}
}
