// SPDX-FileCopyrightText: 2024 Philipp Klein <philipptheklein@gmail.com>
// SPDX-FileCopyrightText: 2023 Kerstin Humm <kerstin@erictapen.name>
//
// SPDX-License-Identifier: GPL-3.0-or-later

#import "@preview/letter-pro:2.1.0": letter-simple

#set text(lang: "de", region: "AT")

#let details = toml("invoice.toml")

// Typst can't format numbers yet, so we use this from here:
// https://github.com/typst/typst/issues/180#issuecomment-1627451769
#let format_currency(number, precision: 2, decimal_delim: ",", thousands_delim: ".") = {
  let integer = str(calc.floor(number))
  if precision <= 0 {
    return integer
  }

  let value = str(calc.round(number, digits: precision))
  let from_dot = decimal_delim + if value == integer {
    precision * "0"
  } else {
    let precision_diff = integer.len() + precision + decimal_delim.len() - value.len()
    value.slice(integer.len() + 1) + precision_diff * "0"
  }

  let cursor = 3
  while integer.len() > cursor {
    integer = integer.slice(0, integer.len() - cursor) + thousands_delim + integer.slice(integer.len() - cursor, integer.len())
    cursor += thousands_delim.len() + 3
  }
  integer + from_dot
}

#show: letter-simple.with(
  sender: (
    name: details.author.name,
    address: details.author.address,
    extra: [

      //UID: #details.author.uid\
      #link(details.author.tel)[#details.author.tel]\
      #link(details.author.email)[#details.author.email]
    ],
  ),

  //annotations: [Einschreiben - Rückschein],
  recipient: [
    #details.recipient.name \
    #details.recipient.co \
    #details.recipient.street \
    #details.recipient.zip #details.recipient.city \
  ],

  information-box: pad(right: 10mm)[
    #set text(size: 10pt)
    #set align(end)

    #v(3.5em)

    Rechnungsnummer \
    #details.invoice-nr

    Kunden UID-Nr. \
    #details.recipient.uid
  ],
  footer: [
    #set text(size: 8pt)
    #details.author.name\
    #details.author.address\
    #details.author.tel | #details.author.email\
    UID: #details.author.uid | IBAN: #details.bank_account.iban
  ],
  margin: (
    bottom: 30mm,
  ),
  date: details.date,
  subject: "Rechnung",
)

Für

== #details.subject


Leistungszeitraum: #details.period \
Projektbezeichnung: #details.project


#let items = details.items.enumerate().map(
  ((id, item)) => (
    [#str(id + 1)],
    [#item.description],
    [#item.at("quantity", default: none)],
    [€ #format_currency(item.price)],
  )).flatten()

#let subtotal = details.items.map((item) => item.at("price")).sum()
#let vatSum = details.vat * subtotal
#let total = subtotal * (1.0 + details.vat)

#let subtotaCell = ()
#if details.items.len() > 1 {
  subtotaCell = (
    [], [], [Summe netto], [€ #format_currency(subtotal)],
  )
}

#[
  #set text(number-type: "lining")
  #table(
    columns: (auto, 8fr, auto, auto),
    align: ((column, row) => if column == 1 { left } else { right }),
    stroke: none,
// --- Header ---
    [*Pos.*], [*Beschreibung*], [], [*Preis*],
    table.hline(),
// --- Positionen ---
    ..items,
    table.hline(),
// --- Netto ---
    ..subtotaCell,
// --- USt. ---
    [], [], [Zzgl. #str(details.vat * 100)% USt.], [€ #format_currency(vatSum)],
    table.hline(start: 2),
// --- Total ---
    [], [], [*Gesamt*], [*€ #format_currency(total)*],
  )
]

#v(1em)

Zahlbar gemäß Vereinbarung auf Konto:

#pad(left: 5mm)[
  #details.bank_account.bank\
  #details.bank_account.iban\
  #details.bank_account.bic
]

#v(1em)

Danke für Ihren Auftrag!

