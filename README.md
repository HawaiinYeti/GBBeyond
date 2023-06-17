# GBBeyond

Make and watch your own [Giant Bomb Infinite](https://www.giantbomb.com/infinite/)-like channels. Create as many channels as you want, set rules for what videos play on each channel and watch the channels in your browser.

![Screenshot 2023-06-16 at 17-26-32 Dashboard GBBeyond](https://github.com/HawaiinYeti/GBBeyond/assets/11588185/2f294671-1fd2-4d50-9a3d-9af51dc4edcf)

## Prerequisites

Before you can run this application, you'll need to have [Docker](https://www.docker.com/products/docker-desktop) installed on your computer

## Getting Started

1. Clone the repository to your local machine:

   ```
   git clone https://github.com/HawaiinYeti/gbbeyond.git
   ```

2. Change your working directory to the project root:

   ```
   cd gbbeyond
   ```

3. Build and run the Docker image:

   ```
   docker compose up
   ```

4. (Optional) Run the container in the background:

   ```
   docker compose up -d
   ```

5. Open your web browser and navigate to http://localhost:8282

6. Set up your Giant Bomb API key at http://localhost:8282/settings

## Contributing

If you'd like to contribute to this project, please follow these steps:

1. Fork the repository on GitHub.

2. Clone your forked repository to your local machine:

   ```
   git clone https://github.com/your-username/gbbeyond.git
   ```

3. Create a new branch to work on:

   ```
   git checkout -b my-feature-branch
   ```

4. Make your changes and commit them:

   ```
   git commit -am 'Add some feature'
   ```

5. Push your changes to your forked repository:

   ```
   git push origin my-feature-branch
   ```

6. Create a pull request on GitHub and describe your changes.

## License

This project is licensed under the [MIT License](LICENSE.md).
