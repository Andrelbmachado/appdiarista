import SwiftUI
import Foundation

struct MarketplaceView: View {
    @State private var selectedCategory: MarketplaceCategory = .all
    @State private var cartItems: [CartItem] = []
    @State private var favoriteProductIDs: Set<UUID> = []
    @State private var searchText = ""
    @State private var filterOptions = MarketplaceFilterOptions()
    @State private var showingFilter = false
    @Namespace private var categoryNamespace
    @Environment(\.colorScheme) private var colorScheme

    private let allProducts = MarketplaceProduct.sample

    private var filteredProducts: [MarketplaceProduct] {
        var results = allProducts
        let trimmedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedSearch.isEmpty {
            let normalized = trimmedSearch.normalized
            results = results.filter { product in
                let searchable = [product.name, product.description]
                return searchable.map { $0.normalized }.contains { $0.contains(normalized) }
            }
        }
        results = results.filter { filterOptions.matches(price: $0.price) }
        if selectedCategory != .all {
            results = results.filter { $0.category == selectedCategory }
        }
        return results
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    header
                    searchBar
                    categoryChips.padding(.top, -8)
                    categoryDivider
                    productGrid
                        .padding(.top, -24)
                }
                .padding()
            }
            .background(Color(.systemGray6).ignoresSafeArea())
            .sheet(isPresented: $showingFilter) {
                MarketplaceFilterView(filter: $filterOptions)
            }
        }
    }

    private var header: some View {
        HStack {
            Text("Marketplace")
                .font(.system(size: 34, weight: .bold, design: .rounded))
            Spacer()
            HStack(spacing: 12) {
                NavigationLink {
                    FavoritesView(products: allProducts, favorites: $favoriteProductIDs)
                } label: {
                    Image(systemName: "heart.fill")
                        .imageScale(.large)
                        .foregroundColor(.red)
                        .padding(8)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 54, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 100, style: .continuous)
                                .stroke(Color.white.opacity(0.8), lineWidth: 1)
                        )
                }
                NavigationLink {
                    CartView(cartItems: $cartItems)
                } label: {
                    Image(systemName: "cart.fill")
                        .imageScale(.large)
                        .foregroundColor(.blue)
                        .padding(8)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 50, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 54, style: .continuous)
                                .stroke(Color.white.opacity(0.8), lineWidth: 1)
                        )
                }
            }
        }
        .padding(.top, 12)
    }

    private var searchBar: some View {
        HStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Buscar produtos", text: $searchText)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(colorScheme == .dark ? Color.white.opacity(0.2) : Color.black.opacity(0.1), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            Button {
                showingFilter = true
            } label: {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .font(.title3)
                    .foregroundColor(.blue)
            }
        }
    }

    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(MarketplaceCategory.allCases) { category in
                    Button {
                        withAnimation(.spring()) {
                            selectedCategory = category
                        }
                    } label: {
            Text(category.displayName)
                .font(.subheadline.bold())
                .padding(.vertical, 6)
                .padding(.horizontal, 16)
                            .foregroundColor(selectedCategory == category ? .white : .primary)
                            .background(
                                ZStack {
                                    if selectedCategory == category {
                                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                                            .fill(Color.blue)
                                            .matchedGeometryEffect(id: "category", in: categoryNamespace)
                                    } else {
                                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                                            .stroke(Color.blue.opacity(0.6), lineWidth: 2)
                                    }
                                }
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 12)
        }
    }

    private var categoryDivider: some View {
        Rectangle()
            .fill(Color.white)
            .frame(height: 8)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, -24)
            .padding(.top, -6)
    }

    private var productGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible(minimum: 0, maximum: .infinity), spacing: 0, alignment: .top), GridItem(.flexible(minimum: 0, maximum: .infinity), spacing: 0, alignment: .top)], spacing: 0) {
            ForEach(filteredProducts) { product in
                NavigationLink {
                    MarketplaceDetailView(product: product) {
                        addToCart(product)
                    }
                } label: {
                    MarketplaceCard(
                        product: product,
                        isFavorite: favoriteProductIDs.contains(product.id),
                        onFavoriteToggle: { toggleFavorite(product) },
                        onBuy: { addToCart(product) }
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, -18)
        .padding(.bottom, 24)
    }

    private func toggleFavorite(_ product: MarketplaceProduct) {
        if favoriteProductIDs.contains(product.id) {
            favoriteProductIDs.remove(product.id)
        } else {
            favoriteProductIDs.insert(product.id)
        }
    }

    private func addToCart(_ product: MarketplaceProduct) {
        if let index = cartItems.firstIndex(where: { $0.product.id == product.id }) {
            cartItems[index].quantity += 1
        } else {
            cartItems.append(CartItem(product: product))
        }
    }
}

struct MarketplaceCard: View {
    let product: MarketplaceProduct
    let isFavorite: Bool
    let onFavoriteToggle: () -> Void
    let onBuy: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack(alignment: .topTrailing) {
                Rectangle()
                    .fill(cardImageBackground)
                    .frame(height: 200)
                    .overlay(productImage)
                favoriteButton
                    .padding(10)
            }

            Text(product.name)
                .font(.headline)
                .foregroundColor(colorScheme == .dark ? .white : .primary)
                .lineLimit(2)
                .frame(maxWidth: .infinity, minHeight: 48, alignment: .leading)

            HStack(alignment: .center, spacing: 12) {
                Text(product.formattedPrice)
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(.blue)
                Spacer()
                Button(action: onBuy) {
                    Image(systemName: "cart.fill")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Circle().fill(Color.blue))
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 260, alignment: .top)
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(cardBackground)
        .overlay(
            Rectangle()
                .stroke(Color(.separator), lineWidth: colorScheme == .dark ? 0.6 : 0.4)
        )
    }

    private var favoriteButton: some View {
        Button(action: onFavoriteToggle) {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .font(.headline)
                .foregroundColor(isFavorite ? .red : .gray)
                .padding(9)
                .background(
                    Circle()
                        .fill(Color.white.opacity(colorScheme == .dark ? 0.3 : 0.9))
                        .shadow(color: Color.black.opacity(0.2), radius: 2)
                )
        }
        .buttonStyle(.plain)
    }

    private var cardBackground: Color {
        colorScheme == .dark ? Color(red: 0.14, green: 0.15, blue: 0.18) : Color(.systemBackground)
    }

    private var cardImageBackground: Color { .white }

    @ViewBuilder
    private var productImage: some View {
        if product.usesAssetImages {
            Image(product.image)
                .resizable()
                .scaledToFit()
                .padding(4)
        } else {
            Image(systemName: product.image)
                .resizable()
                .scaledToFit()
                .padding(12)
                .foregroundColor(.blue.opacity(0.7))
        }
    }
}

struct MarketplaceDetailView: View {
    let product: MarketplaceProduct
    var onAddToCart: (() -> Void)? = nil
    @State private var selectedColorIndex = 0
    @State private var selectedSizeIndex = 0
    @State private var purchaseMessage: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(product.images, id: \.self) { imageName in
                            detailImage(for: imageName)
                                .frame(width: 220, height: 160)
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 24).fill(Color.white))
                                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top)

                VStack(alignment: .leading, spacing: 12) {
                    if product.isTopItem {
                        Text("Top item")
                            .font(.caption2.bold())
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.yellow.opacity(0.9), in: Capsule())
                    }
                    Text(product.name)
                        .font(.title.bold())
                    Text(product.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 24)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Cor")
                        .font(.headline)
                        .padding(.leading, 8)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(product.colors.indices, id: \.self) { index in
                                let color = product.colors[index]
                                Text(color)
                                    .font(.subheadline)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(selectedColorIndex == index ? Color.blue : Color.gray.opacity(0.4), lineWidth: 2)
                                    )
                                    .foregroundColor(selectedColorIndex == index ? .blue : .primary)
                                    .onTapGesture {
                                        selectedColorIndex = index
                                    }
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                    Text("Tamanho")
                        .font(.headline)
                        .padding(.leading, 8)
                    HStack(spacing: 12) {
                        ForEach(product.sizes.indices, id: \.self) { index in
                            let size = product.sizes[index]
                            Text(size)
                                .font(.subheadline)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(selectedSizeIndex == index ? Color.blue : Color(.systemGray5))
                                )
                                .foregroundColor(selectedSizeIndex == index ? .white : .primary)
                                .onTapGesture { selectedSizeIndex = index }
                        }
                    }
                    .padding(.horizontal, 24)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Preço")
                        .font(.headline)
                        .padding(.leading, 8)
                    Text(product.formattedPrice)
                        .font(.system(size: 32, weight: .heavy, design: .rounded))
                        .foregroundColor(.blue)
                }
                .padding(.horizontal, 24)
                Spacer(minLength: 40)
            }
        }
        .background(Color(.systemBackground))
        .navigationTitle("Detalhes")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 12) {
                Button(action: purchaseNow) {
                    Label("Comprar agora", systemImage: "creditcard")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }

                Button(action: { onAddToCart?() }) {
                    Label("Adicionar ao carrinho", systemImage: "cart.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 16)
            .background(.ultraThinMaterial)
        }
        .alert(purchaseMessage ?? "", isPresented: Binding(
            get: { purchaseMessage != nil },
            set: { if !$0 { purchaseMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        }
    }

    private func purchaseNow() {
        purchaseMessage = "Compra direta iniciada para \(product.name). Finalize o pagamento na próxima etapa."
    }

    @ViewBuilder
    private func detailImage(for imageName: String) -> some View {
        if product.usesAssetImages {
            Image(imageName)
                .resizable()
                .scaledToFit()
        } else {
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .foregroundColor(.blue)
        }
    }
}

struct CartView: View {
    @Binding var cartItems: [CartItem]
    @State private var showingPaymentOptions = false
    @State private var paymentMessage: String?

    private var selectedTotal: Decimal {
        cartItems.filter { $0.isSelected }.reduce(Decimal.zero) { $0 + $1.subtotal }
    }

    private var formattedTotal: String {
        CurrencyFormatter.string(from: selectedTotal)
    }

    var body: some View {
        List {
            if cartItems.isEmpty {
                Text("Seu carrinho está vazio.")
                    .foregroundColor(.secondary)
            } else {
                ForEach($cartItems) { $item in
                    CartRowView(item: $item) {
                        removeItem(withID: item.id)
                    }
                }
            }
        }
        .navigationTitle("Carrinho")
        .safeAreaInset(edge: .bottom) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Total selecionado:")
                        .font(.headline)
                    Spacer()
                    Text(formattedTotal)
                        .font(.title3.bold())
                }
                Button(action: { showingPaymentOptions = true }) {
                    Text("Finalizar compra")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedTotal == 0 ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .disabled(selectedTotal == 0)
            }
            .padding()
            .background(.ultraThinMaterial)
        }
        .confirmationDialog("Escolha a forma de pagamento", isPresented: $showingPaymentOptions, titleVisibility: .visible) {
            Button("Cartão de crédito") { paymentMessage = "Insira os dados do cartão para concluir a compra." }
            Button("Apple Pay") { paymentMessage = "Finalize pelo Apple Pay no próximo passo." }
            Button("Pix") { paymentMessage = "Um QR Code/Pix será exibido para pagamento." }
            Button("Cancelar", role: .cancel) {}
        }
        .alert(paymentMessage ?? "", isPresented: Binding(
            get: { paymentMessage != nil },
            set: { if !$0 { paymentMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        }
    }

    private func removeItem(withID id: UUID) {
        guard let index = cartItems.firstIndex(where: { $0.id == id }) else { return }
        cartItems.remove(at: index)
    }
}

struct CartRowView: View {
    @Binding var item: CartItem
    var onRemove: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Button {
                    item.isSelected.toggle()
                } label: {
                    Image(systemName: item.isSelected ? "checkmark.square.fill" : "square")
                        .foregroundColor(item.isSelected ? .blue : .secondary)
                        .font(.title3)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.product.name)
                        .font(.headline)
                    Text(item.product.formattedPrice)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Button(role: .destructive, action: onRemove) {
                    Image(systemName: "trash")
                }
            }
            HStack(alignment: .center, spacing: 12) {
                Text("Quantidade")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                HStack(spacing: 12) {
                    Button {
                        if item.quantity > 1 { item.quantity -= 1 }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .foregroundColor(.blue)
                    }
                    Text("\(item.quantity)")
                        .font(.headline)
                        .frame(minWidth: 24)
                    Button {
                        item.quantity += 1
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .padding(12)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct CartItem: Identifiable {
    let id = UUID()
    let product: MarketplaceProduct
    var quantity: Int = 1
    var isSelected: Bool = true

    var subtotal: Decimal {
        product.price * Decimal(quantity)
    }
}

struct FavoritesView: View {
    let products: [MarketplaceProduct]
    @Binding var favorites: Set<UUID>

    private var favoriteItems: [MarketplaceProduct] {
        products.filter { favorites.contains($0.id) }
    }

    var body: some View {
        List {
            if favoriteItems.isEmpty {
                Text("Você ainda não favoritou nenhum item.")
                    .foregroundColor(.secondary)
            } else {
                ForEach(favoriteItems) { product in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(product.name)
                                .font(.headline)
                            Text(product.formattedPrice)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Button {
                            favorites.remove(product.id)
                        } label: {
                            Image(systemName: favorites.contains(product.id) ? "heart.fill" : "heart")
                                .foregroundColor(favorites.contains(product.id) ? .red : .gray)
                                .imageScale(.large)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .navigationTitle("Favoritos")
    }
}

struct MarketplaceFilterOptions {
    var minPrice: String = ""
    var maxPrice: String = ""

    var minPriceDecimal: Decimal? {
        CurrencyFormatter.decimal(from: minPrice) ?? Decimal(string: minPrice.replacingOccurrences(of: ",", with: "."))
    }

    var maxPriceDecimal: Decimal? {
        CurrencyFormatter.decimal(from: maxPrice) ?? Decimal(string: maxPrice.replacingOccurrences(of: ",", with: "."))
    }

    var hasActiveFilters: Bool {
        !minPrice.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        !maxPrice.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func matches(price: Decimal) -> Bool {
        if let min = minPriceDecimal, price < min { return false }
        if let max = maxPriceDecimal, price > max { return false }
        return true
    }

    mutating func reset() {
        minPrice = ""
        maxPrice = ""
    }
}

struct MarketplaceFilterView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var filter: MarketplaceFilterOptions
    @State private var draft: MarketplaceFilterOptions

    init(filter: Binding<MarketplaceFilterOptions>) {
        self._filter = filter
        self._draft = State(initialValue: filter.wrappedValue)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Preço") {
                    HStack(spacing: 12) {
                        TextField("Mínimo", text: $draft.minPrice)
                            .keyboardType(.numberPad)
                        TextField("Máximo", text: $draft.maxPrice)
                            .keyboardType(.numberPad)
                    }
                }
                if draft.hasActiveFilters {
                    Section {
                        Button("Limpar filtros", role: .destructive) {
                            draft.reset()
                        }
                    }
                }
            }
            .navigationTitle("Filtrar produtos")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Aplicar") {
                        filter = draft
                        dismiss()
                    }
                }
            }
        }
    }
}

struct MarketplaceProduct: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let image: String
    let images: [String]
    let price: Decimal
    let category: MarketplaceCategory
    let isTopItem: Bool
    let colors: [String]
    let sizes: [String]
    let usesAssetImages: Bool

    init(
        name: String,
        description: String,
        image: String,
        images: [String],
        price: Decimal,
        category: MarketplaceCategory,
        isTopItem: Bool,
        colors: [String],
        sizes: [String],
        usesAssetImages: Bool = false
    ) {
        self.name = name
        self.description = description
        self.image = image
        self.images = images
        self.price = price
        self.category = category
        self.isTopItem = isTopItem
        self.colors = colors
        self.sizes = sizes
        self.usesAssetImages = usesAssetImages
    }

    var formattedPrice: String {
        CurrencyFormatter.string(from: price)
    }

    static let sample: [MarketplaceProduct] = [
        MarketplaceProduct(
            name: "Kit Limpeza Profissional",
            description: "Inclui mop, balde, panos e borrifadores.",
            image: "kit_limpeza",
            images: ["kit_limpeza"],
            price: 220,
            category: .cleaning,
            isTopItem: true,
            colors: ["Azul", "Branco"],
            sizes: ["Padrão"],
            usesAssetImages: true
        ),
        MarketplaceProduct(
            name: "Desinfetante Floral",
            description: "Perfeito para banheiros e cozinhas.",
            image: "spray.can.fill",
            images: ["spray.can.fill", "drop", "fan.fill"],
            price: 90,
            category: .chemicals,
            isTopItem: false,
            colors: ["Floral"],
            sizes: ["500ml", "1L"]
        ),
        MarketplaceProduct(
            name: "Saco Multiuso",
            description: "Para descarte de resíduos com segurança.",
            image: "saco_multiuso",
            images: ["saco_multiuso"],
            price: 60,
            category: .cleaning,
            isTopItem: false,
            colors: ["Preto", "Azul"],
            sizes: ["G", "GG"],
            usesAssetImages: true
        ),
        MarketplaceProduct(
            name: "Limpador de Vidros",
            description: "Remove manchas sem deixar marcas.",
            image: "drop.fill",
            images: ["drop.fill", "cloud.drizzle.fill", "sun.max.trianglebadge.exclamationmark"],
            price: 85,
            category: .bathroom,
            isTopItem: true,
            colors: ["Transparente"],
            sizes: ["750ml"]
        ),
        MarketplaceProduct(
            name: "Luvas Premium",
            description: "Material resistente e confortável.",
            image: "luvas_premium",
            images: ["luvas_premium"],
            price: 70,
            category: .bathroom,
            isTopItem: false,
            colors: ["Rosa", "Azul"],
            sizes: ["P", "M", "G"],
            usesAssetImages: true
        ),
        MarketplaceProduct(
            name: "Removedor Extra Forte",
            description: "Ideal para sujeiras difíceis.",
            image: "flame.fill",
            images: ["flame.fill", "smoke.fill", "bolt.fill"],
            price: 130,
            category: .chemicals,
            isTopItem: true,
            colors: ["Clássico"],
            sizes: ["1L", "5L"]
        ),
        MarketplaceProduct(
            name: "Aspirador Portátil Compact",
            description: "Aspira pó e líquidos, bateria com 30 minutos de autonomia.",
            image: "aspirador_compact",
            images: ["aspirador_compact"],
            price: 480,
            category: .equipment,
            isTopItem: true,
            colors: ["Grafite", "Branco"],
            sizes: ["Padrão"],
            usesAssetImages: true
        ),
        MarketplaceProduct(
            name: "Kit Aromatizador Citrus",
            description: "Essências concentradas para salas e escritórios.",
            image: "kit_aromatizador",
            images: ["kit_aromatizador"],
            price: 150,
            category: .accessories,
            isTopItem: false,
            colors: ["Citrus", "Lavanda"],
            sizes: ["250ml", "500ml"],
            usesAssetImages: true
        ),
        MarketplaceProduct(
            name: "Kit Panos Microfibra Premium",
            description: "Conjunto com 12 panos absorventes e duráveis.",
            image: "square.grid.3x3.fill",
            images: ["square.grid.3x3.fill", "rectangle.grid.2x2"],
            price: 95,
            category: .equipment,
            isTopItem: false,
            colors: ["Colorido"],
            sizes: ["30x30cm", "40x60cm"]
        ),
        MarketplaceProduct(
            name: "Balde com Espremedor Turbo",
            description: "Sistema giratório que elimina o excesso de água em segundos.",
            image: "drop.triangle.fill",
            images: ["drop.triangle.fill", "tornado"],
            price: 210,
            category: .equipment,
            isTopItem: true,
            colors: ["Azul", "Vermelho"],
            sizes: ["15L"]
        ),
        MarketplaceProduct(
            name: "Luvas Descartáveis 100un",
            description: "Proteção extra para ambientes com alto giro de clientes.",
            image: "hand.raised.circle.fill",
            images: ["hand.raised.circle.fill", "hand.raised.fill"],
            price: 55,
            category: .accessories,
            isTopItem: false,
            colors: ["Transparente"],
            sizes: ["M", "G"]
        ),
        MarketplaceProduct(
            name: "Rodo com Cabo Inox",
            description: "Lâmina em silicone que não risca o piso.",
            image: "rodo_inox",
            images: ["rodo_inox"],
            price: 115,
            category: .equipment,
            isTopItem: false,
            colors: ["Inox"],
            sizes: ["45cm"],
            usesAssetImages: true
        ),
        MarketplaceProduct(
            name: "Spray Multiuso Eco",
            description: "Limpeza ecológica com fragrância suave.",
            image: "spray_multiuso",
            images: ["spray_multiuso"],
            price: 68,
            category: .chemicals,
            isTopItem: false,
            colors: ["Verde"],
            sizes: ["500ml"],
            usesAssetImages: true
        ),
        MarketplaceProduct(
            name: "Kit Organizadores de Produtos",
            description: "Bandejas e potes para separar itens de limpeza.",
            image: "tray.full.fill",
            images: ["tray.full.fill", "square.grid.2x2.fill"],
            price: 140,
            category: .accessories,
            isTopItem: true,
            colors: ["Branco", "Grafite"],
            sizes: ["M", "G"]
        ),
        MarketplaceProduct(
            name: "Sabão Neutro Concentrado",
            description: "Rende até 20L diluído, ideal para superfícies delicadas.",
            image: "square.fill.text.grid.1x2",
            images: ["square.fill.text.grid.1x2", "drop"],
            price: 125,
            category: .chemicals,
            isTopItem: false,
            colors: ["Neutro"],
            sizes: ["2L"]
        ),
        MarketplaceProduct(
            name: "Escova Multiuso Flex",
            description: "Cerdas duplas para rejuntes e cantos difíceis.",
            image: "escova_flex",
            images: ["escova_flex"],
            price: 72,
            category: .cleaning,
            isTopItem: false,
            colors: ["Amarelo", "Cinza"],
            sizes: ["Padrão"],
            usesAssetImages: true
        ),
        MarketplaceProduct(
            name: "Kit Ganchos Autocolantes",
            description: "10 unidades para pendurar panos e utensílios.",
            image: "paperclip.circle.fill",
            images: ["paperclip.circle.fill", "paperclip"],
            price: 45,
            category: .accessories,
            isTopItem: false,
            colors: ["Transparente"],
            sizes: ["Kit 10"]
        ),
        MarketplaceProduct(
            name: "Sabão em Pó Concentrado",
            description: "Rende o dobro e deixa perfume suave.",
            image: "cube.fill",
            images: ["cube.fill", "square.fill.text.grid.1x2"],
            price: 140,
            category: .chemicals,
            isTopItem: false,
            colors: ["Azul"],
            sizes: ["5kg"]
        ),
        MarketplaceProduct(
            name: "Saco para Aspirador",
            description: "Compatível com modelos portáteis e industriais.",
            image: "doc.zipper",
            images: ["doc.zipper", "folder.fill"],
            price: 60,
            category: .equipment,
            isTopItem: false,
            colors: ["Branco"],
            sizes: ["Pack 5"]
        ),
        MarketplaceProduct(
            name: "Kit Escova + Pá Dobrável",
            description: "Facilita recolher resíduos sem se abaixar.",
            image: "shuffle.circle",
            images: ["shuffle.circle", "arrow.triangle.2.circlepath"],
            price: 120,
            category: .equipment,
            isTopItem: true,
            colors: ["Roxo", "Verde"],
            sizes: ["Padrão"]
        ),
        MarketplaceProduct(
            name: "Luva de Microfibra para Pó",
            description: "Remove poeira sem riscar superfícies sensíveis.",
            image: "hand.wave.fill",
            images: ["hand.wave.fill", "wind"],
            price: 65,
            category: .accessories,
            isTopItem: false,
            colors: ["Azul"],
            sizes: ["Único"]
        ),
        MarketplaceProduct(
            name: "Limpa-Pisos Perfumado",
            description: "Cheiro de lavanda e secagem rápida.",
            image: "drop.circle.fill",
            images: ["drop.circle.fill", "spray.can.fill"],
            price: 80,
            category: .chemicals,
            isTopItem: false,
            colors: ["Lilás"],
            sizes: ["2L"]
        ),
        MarketplaceProduct(
            name: "Kit Proteção para Sofás",
            description: "Aplicação spray cria película contra manchas.",
            image: "sofa.fill",
            images: ["sofa.fill", "paintbrush.pointed"],
            price: 210,
            category: .chemicals,
            isTopItem: true,
            colors: ["Neutro"],
            sizes: ["750ml"]
        ),
        MarketplaceProduct(
            name: "Secador de Piso Profissional",
            description: "Lâmina longa com cabo leve.",
            image: "rectangle.compress.vertical",
            images: ["rectangle.compress.vertical", "arrow.down"],
            price: 180,
            category: .equipment,
            isTopItem: true,
            colors: ["Preto"],
            sizes: ["55cm"]
        ),
        MarketplaceProduct(
            name: "Carrinho Organizer",
            description: "3 andares para transportar produtos e panos.",
            image: "cart.fill",
            images: ["cart.fill", "square.3.layers.3d.down.right"],
            price: 350,
            category: .equipment,
            isTopItem: false,
            colors: ["Branco", "Grafite"],
            sizes: ["Padrão"]
        ),
        MarketplaceProduct(
            name: "Potes Herméticos 6un",
            description: "Armazenamento seguro para produtos químicos.",
            image: "cube.transparent.fill",
            images: ["cube.transparent.fill", "tray.full.fill"],
            price: 99,
            category: .accessories,
            isTopItem: false,
            colors: ["Transparente"],
            sizes: ["Kit 6"]
        ),
        MarketplaceProduct(
            name: "Kit Rodízios para Móveis",
            description: "4 rodas com trava para facilitar deslocamento.",
            image: "circle.hexagonpath",
            images: ["circle.hexagonpath", "circle.grid.cross"],
            price: 165,
            category: .accessories,
            isTopItem: false,
            colors: ["Preto"],
            sizes: ["Kit 4"]
        ),
        MarketplaceProduct(
            name: "Removedor de Ferrugem",
            description: "Age rápido em metais e cromados.",
            image: "scissors.circle",
            images: ["scissors.circle", "sparkles"],
            price: 145,
            category: .chemicals,
            isTopItem: false,
            colors: ["Laranja"],
            sizes: ["1L"]
        ),
        MarketplaceProduct(
            name: "Kit Pulverizadores Mini",
            description: "Três frascos com marcadores de cor.",
            image: "circle.grid.cross",
            images: ["circle.grid.cross", "drop"],
            price: 58,
            category: .accessories,
            isTopItem: false,
            colors: ["Azul", "Verde", "Rosa"],
            sizes: ["100ml"]
        ),
        MarketplaceProduct(
            name: "Cera Líquida Brilho Máximo",
            description: "Protege e realça pisos vinílicos.",
            image: "diamond.fill",
            images: ["diamond.fill", "sparkles"],
            price: 135,
            category: .chemicals,
            isTopItem: true,
            colors: ["Âmbar"],
            sizes: ["1L"]
        ),
        MarketplaceProduct(
            name: "Fitas Antiderrapantes",
            description: "Auto-adesivas para degraus e escadas.",
            image: "line.diagonal.arrow",
            images: ["line.diagonal.arrow", "rectangle.fill"],
            price: 90,
            category: .accessories,
            isTopItem: false,
            colors: ["Preto"],
            sizes: ["5m"]
        ),
        MarketplaceProduct(
            name: "Borrifadores Profissionais",
            description: "Pack com 4 frascos reguláveis.",
            image: "cloud.drizzle.fill",
            images: ["cloud.drizzle.fill", "drop.triangle.fill"],
            price: 120,
            category: .equipment,
            isTopItem: false,
            colors: ["Colorido"],
            sizes: ["500ml"]
        ),
        MarketplaceProduct(
            name: "Kit Rede de Proteção para Tapetes",
            description: "Evita escorregões após lavagem.",
            image: "square.split.2x2.fill",
            images: ["square.split.2x2.fill", "square.fill"],
            price: 85,
            category: .accessories,
            isTopItem: false,
            colors: ["Bege"],
            sizes: ["P", "M", "G"]
        ),
        MarketplaceProduct(
            name: "Detergente Ultra Espuma",
            description: "Limpa louças e utensílios pesados.",
            image: "bubble.left.and.exclamationmark.bubble.right.fill",
            images: ["bubble.left.and.exclamationmark.bubble.right.fill", "drop.fill"],
            price: 65,
            category: .chemicals,
            isTopItem: false,
            colors: ["Verde"],
            sizes: ["1L"]
        ),
        MarketplaceProduct(
            name: "Kit Panos Couro Sintético",
            description: "Alta absorção para secagem rápida.",
            image: "pano_couro",
            images: ["pano_couro"],
            price: 105,
            category: .cleaning,
            isTopItem: false,
            colors: ["Marrom"],
            sizes: ["Pack 5"],
            usesAssetImages: true
        ),
        MarketplaceProduct(
            name: "Kit Organizadores Empilháveis",
            description: "Gavetas transparentes para armário de limpeza.",
            image: "cube.fill.and.line.vertical.fill",
            images: ["cube.fill.and.line.vertical.fill", "cube.transparent.fill"],
            price: 210,
            category: .accessories,
            isTopItem: true,
            colors: ["Transparente"],
            sizes: ["3 módulos"]
        ),
        MarketplaceProduct(
            name: "Kit Tapetes Absorventes",
            description: "Dois tapetes antiderrapantes para área de serviço.",
            image: "square.fill.on.circle.fill",
            images: ["square.fill.on.circle.fill", "square.fill"],
            price: 160,
            category: .accessories,
            isTopItem: false,
            colors: ["Grafite"],
            sizes: ["80x120cm"]
        ),
        MarketplaceProduct(
            name: "Escada de Alumínio 4 Degraus",
            description: "Suporta até 120kg e facilita o acesso a locais altos.",
            image: "ladder.fill",
            images: ["ladder.fill", "square.stack.3d.up.fill"],
            price: 360,
            category: .equipment,
            isTopItem: false,
            colors: ["Alumínio"],
            sizes: ["Altura 1,5m"]
        ),
        MarketplaceProduct(
            name: "Kit Esponjas Antibacterianas",
            description: "Composto por 6 esponjas com proteção antibac.",
            image: "esponjas",
            images: ["esponjas"],
            price: 48,
            category: .cleaning,
            isTopItem: false,
            colors: ["Amarelo", "Verde"],
            sizes: ["Pack 6"],
            usesAssetImages: true
        ),
        MarketplaceProduct(
            name: "Mop Spray 360",
            description: "Borrifador integrado e cabeça articulada.",
            image: "paintbrush.pointed.fill",
            images: ["paintbrush.pointed.fill", "tornado"],
            price: 230,
            category: .equipment,
            isTopItem: true,
            colors: ["Turquesa"],
            sizes: ["Padrão"]
        ),
        MarketplaceProduct(
            name: "Toalhas Absorventes Extra",
            description: "Kit com 8 toalhas superabsorventes.",
            image: "rectangle.3.offgrid",
            images: ["rectangle.3.offgrid", "rectangle.fill"],
            price: 110,
            category: .accessories,
            isTopItem: false,
            colors: ["Cinza", "Branco"],
            sizes: ["35x35cm"]
        ),
        MarketplaceProduct(
            name: "Polidor Multifuncional",
            description: "Remove manchas de inox, vidro e cerâmica.",
            image: "sparkle.magnifyingglass",
            images: ["sparkle.magnifyingglass", "sparkles"],
            price: 98,
            category: .chemicals,
            isTopItem: false,
            colors: ["Neutro"],
            sizes: ["500ml"]
        ),
        MarketplaceProduct(
            name: "Kit Protetores de Piso",
            description: "Fitas e pads para cadeiras e mesas.",
            image: "square.grid.2x2.fill",
            images: ["square.grid.2x2.fill", "square.grid.3x3.fill"],
            price: 75,
            category: .accessories,
            isTopItem: false,
            colors: ["Neutro"],
            sizes: ["Kit 20 un"]
        ),
        MarketplaceProduct(
            name: "Lavadora Portátil",
            description: "Pressão de 1200W, ideal para tapetes.",
            image: "washer.fill",
            images: ["washer.fill", "fan.fill"],
            price: 520,
            category: .equipment,
            isTopItem: true,
            colors: ["Cinza"],
            sizes: ["Padrão"]
        ),
        MarketplaceProduct(
            name: "Escada de Alumínio 4 Degraus",
            description: "Suporta até 120kg e facilita o acesso a locais altos.",
            image: "ladder.fill",
            images: ["ladder.fill", "square.stack.3d.up.fill"],
            price: 360,
            category: .equipment,
            isTopItem: false,
            colors: ["Alumínio"],
            sizes: ["Altura 1,5m"]
        )

    ]
}

enum MarketplaceCategory: String, CaseIterable, Identifiable {
    case all
    case cleaning
    case chemicals
    case bathroom
    case equipment
    case accessories

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .all: return "Todos"
        case .cleaning: return "Itens"
        case .chemicals: return "Químicos"
        case .bathroom: return "Banheiro"
        case .equipment: return "Equipamentos"
        case .accessories: return "Acessórios"
        }
    }
}

#Preview {
    MarketplaceView()
}
