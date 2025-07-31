
use ntex::web::{self, App, HttpRequest};

async fn index(_req: HttpRequest) -> &'static str {
    "Hello world!"
}

#[ntex::main]
async fn main() -> std::io::Result<()> {
    web::server(|| {
        App::new()
            .service(web::resource("/").to(index))
    })
    .bind("127.0.0.1:8080")?
    .run()
    .await
}
