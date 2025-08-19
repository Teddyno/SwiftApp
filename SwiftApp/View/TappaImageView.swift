import SwiftUI

struct TappaImageView: View {
    let titolo:String
    let foto:String
    @State private var imageURL:String=""
    @State private var notFound=false
    
    
    var body: some View {
        if notFound{
            placeholderImage
        }else{
            AsyncImage(url: URL(string: imageURL)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(10)
                        .frame(maxWidth: .infinity,maxHeight: 600)
                        .clipped()
                case .empty:
                    ProgressView()
                        .frame(width: 300,height: 200)
                        .tint(.mint)
                case  .failure:
                    placeholderImage
                @unknown default:
                    placeholderImage
                }
            }
            .task {
                await fetchImageURL()
            }
        }
    }
    
    private var placeholderImage: some View {
        Image(systemName: "photo")
            .resizable()
            .scaledToFill()
            .foregroundColor(.gray)
    }
    
    private func fetchImageURL() async {
        if let link=await Self.fetchDiretto(indirizzo: foto){
            imageURL=link.absoluteString
            return
        }
        
        if let wikiURL = await fetchFromPageSummary() {
            imageURL = wikiURL
            return
        }
        
        if let commonsURL = await Self.fetchFromCommons(placeName: titolo)?.absoluteString {
            imageURL = commonsURL
            return
        }
        notFound=true
        print("Nessuna immagine trovata per: \(titolo)")
    }
    
    private static func fetchDiretto(indirizzo: String) async -> URL? {
        guard let url = URL(string: indirizzo) else { return nil }
        
        do {
            var request = URLRequest(url: url)
            request.httpMethod = "HEAD"
            
            let (_, response) = try await URLSession.shared.data(for: request)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                return nil
            }
            return url
        } catch {
            print("Errore Commons: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func fetchFromPageSummary() async -> String? {
        let query = titolo.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? titolo
        let urlString = "https://en.wikipedia.org/api/rest_v1/page/summary/\(query)"
        
        guard let url = URL(string: urlString) else { return nil }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            
            if let thumbnail = json?["thumbnail"] as? [String: Any],
               let source = thumbnail["source"] as? String,
               !source.isEmpty {
                return source
            }
            return nil
        } catch {
            print("Errore Wikipedia API: \(error.localizedDescription)")
            return nil
        }
    }
    
    private static func fetchFromCommons(placeName: String) async -> URL? {
        let formattedName = placeName
            .replacingOccurrences(of: " ", with: "_")
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? placeName
        
        let commonsUrl = "https://commons.wikimedia.org/wiki/Special:FilePath/\(formattedName).jpg"
        
        guard let url = URL(string: commonsUrl) else { return nil }
        
        do {
            // Verifica rapida senza scaricare l'immagine completa
            var request = URLRequest(url: url)
            request.httpMethod = "HEAD"
            
            let (_, response) = try await URLSession.shared.data(for: request)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                return nil
            }
            return url
        } catch {
            print("Errore Commons: \(error.localizedDescription)")
            return nil
        }
    }
}
